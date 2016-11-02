enum Ensure
{
    Absent
    Present
}

[DscResource()]
class MS_xVisualStudio
{
    [DscProperty(Key)]
    [string] $ProductName

    [DscProperty(Mandatory)]
    [string] $ExecutablePath

    [DscProperty(Mandatory)]
    [string] $AdminDeploymentFile

    [DscProperty()]
    [string] $ProductKey

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(NotConfigurable)]
    [bool] $IsValid


    [MS_xVisualStudio] Get()
    {
        $vsPackage = $this.GetInstalledSoftwares() |? {$_.DisplayName -eq $this.ProductName}
        if(($this.Ensure -eq [Ensure]::Present) -and $vsPackage)
        {
            $this.IsValid = $true
        }
        else
        {
            $this.IsValid = $false
        }
        return $this
    }

    [void] Set()
    {
        if(-not (Test-Path $this.ExecutablePath))
        {
            throw "Invalid path : $($this.ExecutablePath)"
        }
        
        if($this.Ensure -eq [Ensure]::Present)
        {
            if(-not (Test-Path $this.AdminDeploymentFile))
            {
                throw "Invalid path : $($this.AdminDeploymentFile)"
            }

            $args = "/Quiet /NoRestart /AdminFile $($this.AdminDeploymentFile) /Log $Env:Temp\VisualStudio_$(Get-Date -Format "MM-dd-yyyy_hh-mm-ss")_Install.log"
                     
            if($this.ProductKey)
            {
                $args = $args + " /ProductKey $this.ProductKey"
            }
            
            "Installation arguments : $args" | Write-Verbose

            "Starting installation" | Write-Verbose

            Start-Process -FilePath $this.ExecutablePath -ArgumentList $args -Wait -NoNewWindow       

            "Successfully completed the installation" | Write-Verbose
         }
         else
         {
            $args = "/Quiet /Force /Uninstall /Log $Env:Temp\VisualStudio_$(Get-Date -Format "MM-dd-yyyy_hh-mm-ss")_Install.log"

            "Uninstallation arguments : $args" | Write-Verbose
            "Starting uninstallation" | Write-Verbose

            Start-Process -FilePath $this.ExecutablePath -ArgumentList $args -Wait -NoNewWindow       

            "Successfully completed the uninstallation" | Write-Verbose
          }
       }


    [bool] Test()
    {
        $vsPackage = $this.GetInstalledSoftwares() |? {$_.DisplayName -eq $this.ProductName}
        if($this.Ensure -eq [Ensure]::Present)
        {
            if($vsPackage)
            {
                return $true
            }
            else
            {
                return $false
            }
         }
         else
         {
            if($vsPackage)
            {
                return $false
            }
            else
            {
                return $true
            }
         }
    }

    [PSObject[]] RetrievePackages($path, $registry)
    {
        $packages = @()
        $key = $registry.OpenSubKey($path) 
        $subKeys = $key.GetSubKeyNames() |% {
            $subKeyPath = $path + "\\" + $_ 
            $packageKey = $registry.OpenSubKey($subKeyPath) 
            $package = New-Object PSObject 
            $package | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($packageKey.GetValue("DisplayName"))
            $package | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($packageKey.GetValue("DisplayVersion"))
            $package | Add-Member -MemberType NoteProperty -Name "UninstallString" -Value $($packageKey.GetValue("UninstallString")) 
            $package | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($packageKey.GetValue("Publisher"))            
            $packages += $package      
        }
        return $packages
    }

    [PSCustomObject] GetInstalledSoftwares()
    {
        $installedSoftwares = @{}
        $path = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 
        $registry32 = [microsoft.win32.registrykey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
        $registry64 = [microsoft.win32.registrykey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
        
        $packages = $this.RetrievePackages($path, $registry32)
        $packages += $this.RetrievePackages($path, $registry64)


        $packages.Where({$_.DisplayName}) |% { 
            if(-not($installedSoftwares.ContainsKey($_.DisplayName)))
            {
                $installedSoftwares.Add($_.DisplayName, $_) 
            }
        }
        return $installedSoftwares.Values
    }
}