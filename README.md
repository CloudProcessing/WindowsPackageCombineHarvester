```PowerShell: 5.1+ | Platform: Win 10 / 11 / Server 2025```

A PowerShell tool for reviewing removable Appx package bundles, actively tested on Windows 10, Windows 11, and supported Windows Server releases through Windows Server 2025. It is written in PowerShell 5.1 for compatibility reasons.

It enumerates removable Appx packages (`Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage`), combining packages with the same name into a bundle together with the corresponding provisioned Appx package (`Microsoft.Dism.Commands.AppxPackageObject`), if one exists.

Packages of different architectures within a bundle are grouped by version and sorted in descending version order. This shows current and outdated package versions and lets you choose whether to remove outdated versions only, where that option is available, or remove the entire bundle.

The script must be run with administrative rights.

***

You may use the following switches, which can be combined:

### `.\wpch.ps1 -log`

Creates a log file in `%PUBLIC%\Desktop` so you can inspect it immediately.

### `.\wpch.ps1 -verbose`

Displays additional details for each object to support better decision-making.

### `.\wpch.ps1 -list`

Lists all bundles without deleting anything.

### You may want to uncomment some of these lines to make switch parameters permanent

![Switches](https://github.com/CloudProcessing/WindowsPackageCombineHarvester/blob/0346dbff2ea079fc214be032f0cfb5644620ea87/img/260907231023.jpg)

***

Before running the script, check that your PowerShell session has Administrator rights. Also check whether you are allowed to run unsigned PowerShell scripts:
```powershell
Get-ExecutionPolicy
```

If your execution policy prevents locally created scripts from running, you may use the following command for the current user:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Run the script:
```powershell
.\wpch.ps1
```
Use the `Enter` key to browse software bundles one by one. Where available, you will be offered the choice to remove outdated versions only or remove the entire bundle.

At each step, you can press `Space`, then press `Enter`, to skip browsing and proceed to the final confirmation stage.

Whenever you select packages for removal, the script displays an updated list of the selected objects. No selected package is removed until the final stage, when the complete removal list is displayed one last time and you can either confirm removal or cancel.

> [!WARNING]
> The script does not remove selected packages until final confirmation. However, removal can affect Windows features, applications, data, recovery behavior, or system stability. Do not remove a package unless you understand its purpose on the specific computer.

If significant packages are removed, you may lose essential data or reach a state where reinstalling Windows is necessary.

The script can help system administrators identify unwanted bloatware or package bundles on different Windows platforms and versions. However, after
many experiments, I decided not to maintain a built-in ``blacklist`` of potentially unwanted, or a ``whitelist`` of useful Appx bundles. A package that is unnecessary on one system may be required on another, depending on the Windows installation, edition, configuration, and the user.

You are responsible for reviewing the removal list and for the actions you perform.

For a safe first inspection, run:
```powershell
.\wpch.ps1 -log -list
```
This lists package bundles and creates a log without attempting removal. It can help you understand how software is organized and how many outdated package versions are installed.

Removing outdated versions only is in most cases a harmless operation.

If you are unsure about the consequences of the removal, create a full-system backup or disk image copy before proceeding.

You can also run:
```powershell
.\wpch.ps1 -log -verbose -list
```
Review the output carefully and discuss it with best friends of human kind to build the significant packages removal list.

### You may want to comment out these lines to learn how the script works without allowing removal actions
![Removal](https://github.com/CloudProcessing/WindowsPackageCombineHarvester/blob/7df0db0fa3ec494ca0c77ea0fbdf677510671395/img/260907235342.jpg)

### 📄 License
This project is licensed under the **Apache License 2.0** - see the [LICENSE](LICENSE) file for the full text.

*SPDX-License-Identifier: Apache-2.0*
