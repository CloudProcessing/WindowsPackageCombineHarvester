This is a fully working tool, tested on Windows 10/11 and Windows Server versions up to 2025,
written in Powershell 5.1 for compatibility reasons.
It scrolls through all removable Appx Packages (Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage)
combining them in a bundle in case they've got the same name, together with the
respectful Appx Provisioned Package (Microsoft.Dism.Commands.AppxPackageObject) if one exists.
Packages of different architecture within a bundle are being grouped by the same version, and descendingly sorted,
showing you the actual and outdated packages, and in this case providing you the choice to make the decision to remove
outdated packages only, or the whole bundle.
The script should be run with administrative rights,

You may use some switches (in any combinations):
.\wpch.ps1 -log
- creates the log file in %PUBLIC%\Desktop so you can immediately check it,
as well as it stays there in case you're operating in oobe mode
.\wpch.ps1 -verbose
- to expose each object details, for better decision making
.\wpch.ps1 -list
- to list all bundles without deleting anything
