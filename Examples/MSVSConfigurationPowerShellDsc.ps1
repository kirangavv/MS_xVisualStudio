cls
Configuration VistualStudio
{
    
    Param(
        [Parameter(Mandatory=$True)]
        [String[]]$ComputerName
    )
    
    Import-DSCResource -Name MS_xVisualStudio  
    
    MS_xVisualStudio VistualStudio
    {
        ExecutablePath = "\\Share\Packages\VSUltimate2013\SP3\vs_ultimate.exe"
        ProductName = "Microsoft Visual Studio Ultimate 2013 with Update 4"
        AdminDeploymentFile = "\\Share\Packages\VSUltimate2013\SP3\AdminDeployment.xml"
        Ensure = "Present"        
    }   
}


$machineName = $env:COMPUTERNAME
VistualStudio  -ComputerName $machineName -output C:\PDSC
#Start-DscConfiguration -Path C:\PDSC -wait -Force -Verbose
