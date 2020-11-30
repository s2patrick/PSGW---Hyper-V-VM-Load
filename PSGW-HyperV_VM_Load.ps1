# This script shows the number of VMs hosted on all Hyper-V hosts.
# Script can be used in SCOM 2012 R2 UR2 (or newer) Dashboards using PowerShell Grid Widget.
#
# Author:  Patrick Seidl
# Company: Syliance IT Services
# Website: www.syliance.com
# Blog:    www.SystemCenterRocks.com
#
# Please rate if you like it:
# https://gallery.technet.microsoft.com/systemcenter/PSGW-Hyper-V-VM-Load-f1a7c0be


$allHV = Get-SCOMClass -Name Microsoft.Windows.HyperV.ServerRole | Get-SCOMClassInstance
$allSA = Get-SCOMClass -Name Microsoft.SystemCenter.Agent | Get-SCOMClassInstance
$allWC = Get-SCOMClass -Name Microsoft.Windows.Computer | Get-SCOMClassInstance
$allVM = Get-SCOMClass -Name Microsoft.Windows.HyperV.VirtualMachine | Get-SCOMClassInstance

foreach ($eachHV in $allHV) {
    $WCcount = 0
    $VMcount = 0
    $NMcount = 0

    foreach ($eachWC in $allWC) {
        if ($allSA.DisplayName -contains $eachWC.DisplayName) {
            if ($eachWC.'[Microsoft.Windows.Computer].HostServerName'.Value -eq  $eachHV.Name) { $WCcount = $WCcount + 1 }
        }
    }

    foreach ($eachVM in $allVM) {
        if ($eachVM.'[Microsoft.Windows.HyperV.VirtualMachine].ServerName'.Value -eq  $eachHV.Name) { $VMcount = $VMcount + 1 }
    }

    $NMcount = $VMcount - $WCcount

    $dataObject = $ScriptContext.CreateInstance("xsd://foo!bar/baz")
    $dataObject["Id"] = [String]($eachHV.Name)
    $dataObject["Hyper-V Name"] = [String]($eachHV.Name)
    $dataObject["All VMs count"] = [String]($VMcount)
    $dataObject["Managed VMs count"] = [String]($WCcount)
    $dataObject["Unmanaged VMs count"] = [String]($NMcount)
    $ScriptContext.ReturnCollection.Add($dataObject)
}
