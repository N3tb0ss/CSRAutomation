$VIServer = "vcenter01.fatpacket.home"
$VIUsername = "root@vsphere.local"
$VIPassword = "VMware1!"
$VIDataCenter = "HomeLab01"
$VICluster = "MgmtCluster"
$VMDatastore = "NETAPP01-ISCSI-VMDatastore01"
$NestedNetworkPG1 = "VMNet"
$NestedNetworkPG2 = "VIRL-Flat"
$NestedNetworkPG3 = "VIRL-Flat1"
# DeploymentSize Options are 1CPU-4GB or 2CPU-4GB or 4CPU-4GB or 4CPU-8GB
$DeploymentSize = "1CPU-4GB"

$NestedCSRApplianceOVA = "Z:\bscalan\Downloads\csr1000v-universalk9.16.05.01b.ova"

$pESXi = Connect-VIServer $VIServer -User "root@vsphere.local" -Password "VMware1!" -WarningAction SilentlyContinue

$datastore = Get-Datastore -Server $pEsxi -Name $VMDatastore
# $vmhost = Get-VMHost -Server $pEsxi  ### original code block
# Updated code to support selecting a specific cluster
$vmhost = Get-Cluster $VICluster | Get-VMHost | Select -First 1
# $network = Get-VirtualPortGroup -Server $pEsxi -Name $VMNetwork -VMHost $vmhost
$network1 = Get-VDPortGroup -Server $pEsxi -Name $NestedNetworkPG1
$network2 = Get-VDPortGroup -Server $pEsxi -Name $NestedNetworkPG2
$network3 = Get-VDPortGroup -Server $pEsxi -Name $NestedNetworkPG3

$VMName = "CSR1000v-2"

$ovfConfig = Get-OvfConfiguration -Ovf $NestedCSRApplianceOVA
$ovfConfig.NetworkMapping.GigabitEthernet1.Value = $network1
$ovfConfig.NetworkMapping.GigabitEthernet2.Value = $network2
$ovfConfig.NetworkMapping.GigabitEthernet3.Value = $network3
$ovfConfig.DeploymentOption.Value = $DeploymentSize
$ovfConfig.com.cisco.csr1000v.1.hostname.Value = $VMName
$ovfConfig.com.cisco.csr1000v.1.login_username.Value = "admin"
$ovfConfig.com.cisco.csr1000v.1.login_password.Value = "VMware1!"
$ovfConfig.com.cisco.csr1000v.1.mgmt_interface.Value = "GigabitEthernet1"
$ovfConfig.com.cisco.csr1000v.1.mgmt_vlan.Value = "10"
$ovfConfig.com.cisco.csr1000v.1.mgmt_ipv4_addr.Value = "10.10.10.237/24"
$ovfConfig.com.cisco.csr1000v.1.mgmt_ipv4_gateway.Value = "10.10.10.1"
$ovfConfig.com.cisco.csr1000v.1.mgmt_network.Value = "10.10.10.0/24"
$ovfConfig.com.cisco.csr1000v.1.enable_scp_server.Value = "True"
$ovfConfig.com.cisco.csr1000v.1.enable_ssh_server.Value = "True"
$ovfConfig.com.cisco.csr1000v.1.privilege_password.Value = "VMware1!"
$ovfConfig.com.cisco.csr1000v.1.domain_name.Value = "fatpacket.lab"
$ovfConfig.com.cisco.csr1000v.1.license.Value = "ax"
$ovfConfig.com.cisco.csr1000v.1.resource_template.Value = "default"


$vm = Import-VApp -Server $pEsxi -Source $NestedESXiApplianceOVA -OvfConfiguration $ovfconfig -Name $VMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
            