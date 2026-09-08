# SPDX-FileCopyrightText: 2026 CloudProcessing
# SPDX-License-Identifier: Apache-2.0
param (
   [switch]$log = $false,
   [switch]$verbose = $false,
   [switch]$list = $false
)
# [bool]$log = $true
# [bool]$verbose = $true
# [bool]$list = $true
# In case of policy errors, run the command below separately:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Clear-Host
[object]$id = New-Object Security.Principal.WindowsPrincipal($([Security.Principal.WindowsIdentity]::GetCurrent()))
[object]$admin = [Security.Principal.WindowsBuiltInRole]::Administrator
[string]$policy = Get-ExecutionPolicy
$logpath = "$env:PUBLIC\Desktop\$(Get-Date -Format "yyMMddHHmmss")_wpch.log"
if ( $id.IsInRole($admin) ) {
    if ( $log ) {
        "Windows Package Combine Harvester initialized $(Get-Date) as $policy" | Tee-Object -FilePath $logpath -Append | Out-String
        sleep 1.5
    } else {
        "Windows Package Combine Harvester initialized $(Get-Date) as $policy" | Out-String
        sleep 1.5
    }
} else {
    $( "Windows Package Combine Harvester not initialized $(Get-Date) as $policy,"
    "must be run from an elevated Windows session as administrator") | Out-String
    sleep 2.5
    exit 1
}
[System.Collections.Generic.List[string]]$wapmbin = $null
[System.Collections.Generic.List[string]]$dismbin = $null
function SHowRemovalList {
    if ( $dismbin ) {
        $( "$([char]10)Provision Packages to remove:"
        $dismbin ) | Out-String
    }
    if ( $wapmbin ) {
        $( "Packages to remove:"
        $wapmbin ) | Out-String
    }
}
# [array]$spawn =  [psobject]@()
Get-AppxPackage -AllUsers | Where-Object -Property NonRemovable -NE $true | Group-Object -Property Name | ForEach-Object -Begin {
    [int]$i = 0
    [array]$sapling = [pscustomobject]@($null)
    [pscustomobject]$seed = $null
} -Process { $i++
    [pscustomobject]$spawn_ = $_
    [System.Collections.Generic.List[string]]$logmsg = $null
    $logmsg += $(
        "- Bundle $($i) $($spawn_.Name) of $($spawn_.Count) packages$([char]10)"
    )
    $seed = Get-AppxProvisionedPackage -Online | Where-Object -Property DisplayName -EQ $spawn_.Name
    $sapling = $_.Group | Group-Object  -Property { [version]$_.Version } | Sort-Object -Descending { [version]$_.Name }
    $sapling | ForEach-Object -Begin {
        [int]$j = 0
        [array]$sprout = [pscustomobject]@($null)
    } -Process { $j++
        [pscustomobject]$sapling_ = $_
        $logmsg += $(
            if ($j -eq 1) {
                if ( $seed ) {
                    if ($seed.Version -gt [version]$sapling_.Name) {
                        $seed | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $false
                        $( "Provisioned package $($seed.Version.ToString()) is newer"
                        "$($seed.PackageName) $([char]10)" )
                    } elseif ($seed.Version -eq [version]$sapling_.Name) {
                        $seed | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $true
                        $( "Provisioned package $($seed.Version.ToString()) is actual"
                        "$($seed.PackageName) $([char]10)" )
                    } else {
                        $seed | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $false
                        $( "Provisioned package $($seed.Version.ToString()) is outdated"
                        "$($seed.PackageName) $([char]10)" )
                    }
                    if ( $verbose ) { $seed | Format-List | Out-String }
                } else {
                    if ( $verbose ) { "No Provisioned package in the bundle $($spawn_.Name)" | Out-String }
                }
                $sapling_ | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $true
                $sapling_.Group | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $true
            } else {
                $sapling_ | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $false
                $sapling_.Group | Add-Member -MemberType NoteProperty -Force -Name 'IsActual' -Value $false
            }
        )
        $sprout = $sapling_.Group | Sort-Object -Descending { $_.Architecture }
        $sprout | ForEach-Object -Begin {
            [int]$k = 0
        } -Process { $k++
            [psobject]$sprout_ = $_
            $logmsg += $(
                if ( $sprout_.IsActual ) { $(
                    "Actual package $($k)/$($sprout.Count) $($sprout_.Version) $($sprout_.Architecture)"
                    "$($sprout_.PackageFullName) $([char]10)"
                ) } else { $(
                    "Outdated package $($k)/$($sprout.Count) $($sprout_.Version) $($sprout_.Architecture)"
                    "$($sprout_.PackageFullName) $([char]10)"
                ) }
                if ( $verbose ) { $sprout_ | Format-List | Out-String }
            )
        }
    }
    $logmsg += $("- End of the bundle $($i) $($spawn_.Name) $([char]10)")
    if (-not $list) { Clear-Host }
    $logmsg | Out-String
    if (-not $list) {
        if ( ($sapling[0].IsActual) -and ($sapling[1]) ) { # -and (!$sapling[1].IsActual)
            switch -Wildcard (
                $(Read-Host "(A)ll to remove the whole bundle, (O)oudated packages only,$([char]10)Space to finalize or Enter to continue")
            ) {
                ( 'a*' ) {
                    if ($seed) { $dismbin += $seed.PackageName }
                    $spawn_.Group.PackageFullName | ForEach-Object { $wapmbin += $_ }
                    $logmsg += $( ShowRemovalList )
                    ShowRemovalList
                    pause
                }
                ( 'o*' ) {
                    $spawn_.Group | Where-Object -Property IsActual -NE $true | ForEach-Object { $wapmbin += $_.PackageFullName }
                    $logmsg += $( ShowRemovalList )
                    ShowRemovalList
                    pause
                }
                ( ' *' ) {
                    $list = $true
                }
            }
        } else {
            switch -Wildcard (
                $(Read-Host "(R)emove the whole bundle,$([char]10)Space to finalize or Enter to continue")
            ) {
                ( 'r*' ) {
                    if ($seed) { $dismbin += $seed.PackageName }
                    $spawn_.Group.PackageFullName | ForEach-Object { $wapmbin += $_ }
                    $logmsg += $( ShowRemovalList )
                    ShowRemovalList
                    pause
                }
                ( ' *' ) {
                    $list = $true
                }
            }
        }
    }
    if ( $log ) { $logmsg | Out-File $logpath -Append }
} -End {
    $logmsg = $null
    if ($wapmbin) {
        ShowRemovalList
        switch -Wildcard (
            $(Read-Host "(P)roceed to remove listed packages or any key to cancel")
        ) {
            ( 'p*' ) {
                if ( $dismbin ) {
                    $dismbin | ForEach-Object -Begin {
                        [string]$dism_ = $null
                    } -Process {
                        $dism_ = $_
                        $logmsg += $( try {
                            Remove-AppxProvisionedPackage -Online -PackageName $dism_ -AllUsers -LogLevel WarningsInfo -Verbose -ErrorAction Continue
                            "Removed provisioned package $($dism_)"
                        } catch {
                            "Provisioned package $($dism_) not removed $($_.Exception.Message)"
                        } )
                    }
                }
                if ( $wapmbin ) {
                    $wapmbin | ForEach-Object -Begin {
                        [object]$wapm_ = $null
                    } -Process {
                        $wapm_ = $_
                        $logmsg += $( try {
                            Remove-AppxPackage -Package $wapm_ -AllUsers -Verbose -ErrorAction Continue
                            "Removed package $($wapm_)"
                        } catch {
                            "Package $($wapm_) not removed $($_.Exception.Message)"
                        } )
                    }
                }
            }
            default {
                "No changes have been made, canceled."
            }
        }
        $logmsg | Out-String
    }
    if ( $log ) {
        $logmsg | Out-File $logpath -Append
        "Windows Package Combine Harvester concluded $(Get-Date)" | Tee-Object -FilePath $logpath -Append | Out-String
    } else {
        "Windows Package Combine Harvester concluded $(Get-Date)" | Out-String
    }
}
