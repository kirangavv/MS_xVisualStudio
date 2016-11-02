
Configuration MSVSConfigurationAzureDSC{

    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DSCResource -Name MS_xVisualStudio  

    Node "InstallVisualStudio" {
    
        MS_xVisualStudio VistualStudio2013
        {
            ExecutablePath = "\\Share\Packages\VSUltimate2013\SP3\vs_ultimate.exe"
            ProductName = "Microsoft Visual Studio Ultimate 2013 with Update 4"
            AdminDeploymentFile = "\\Share\Packages\VSUltimate2013\SP3\AdminDeployment.xml"
            Ensure = "Present"        
        }
    }
}

