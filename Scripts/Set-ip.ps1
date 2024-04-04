param
(
    [int]$IPLastOctet,
    [string]$HostName
)
$interfacealias = (get-netadapter).interfacealias

if ((Get-NetIPConfiguration -InterfaceAlias $interfacealias | Select -ExpandProperty NetIPv4Interface).DHCP -eq "Enabled") {
    $interface = get-netipconfiguration -interfacealias $interfacealias
    $InterfaceIndex = (Get-NetIPInterface -InterfaceAlias $interfacealias).InterfaceIndex
    #Get ipv4 address
    $ipaddress = $interface.ipv4address.ipv4address
    #get default gateway
    $ipgateway = $interface.ipv4defaultgateway.nexthop
    #to get the subnet mask we need to use wmi object
    $interface2 = get-wmiobject -class win32_networkadapterconfiguration | where-object {$_.defaultipgateway -ne $null}
    #Getting the subnet mask
    $ipsubnet = $interface2.ipsubnet | select-object -first 1
    #We have to convert subnet mask to cidr notation
    $mask = $ipsubnet.split(".")
    $cidr = [int] 0
    $octet = [int] 0
    foreach ($octet in $mask) {
        if ($Octet -eq 255){$CIDR += 8}
        if ($Octet -eq 254){$CIDR += 7}
        if ($Octet -eq 252){$CIDR += 6}
        if ($Octet -eq 248){$CIDR += 5}
        if ($Octet -eq 240){$CIDR += 4}
        if ($Octet -eq 224){$CIDR += 3}
        if ($Octet -eq 192){$CIDR += 2}
        if ($Octet -eq 128){$CIDR += 1}
    } #end foreach
    #Output
    write-host "Interface $interfacealias IPv4 Address DHCP is: "
    write-host "   Address  $ipaddress"
    write-host "   Subnet   $ipsubnet"
    write-host "   Gateway  $ipgateway"
    write-host "   CIDR     $cidr"
    write-host

    if ($IPLastOctet) {
        $octets = $ipaddress.Split(".")                        # or $octets = $IP -split "\."
        $octets[3] = $IPLastOctet     # or other manipulation of the third octet
        $ipaddress = $octets -join "."
        write-host "   New Address  $ipaddress"
    }


    write-host "Setting up the address to static ..."
    remove-netipaddress -interfacealias $interfacealias -addressfamily ipv4 -Confirm:$false
    new-netipaddress -interfacealias $interfacealias -ipaddress $ipaddress -prefixlength $cidr -defaultgateway $ipgateway
	# netsh interface ipv4 add dnsserver name=$interfacealias address=8.8.8.8 index=1 validate=no
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses ($ipgateway,"8.8.8.8")
    write-host "Your ip address is now static ..."
    write-host #theEnd
} else {write-host "Interface $interfacealias Have Static ip ! "}

if ((Get-NetIPConfiguration -InterfaceAlias $interfacealias | Select -ExpandProperty NetIPv6Interface).DHCP -eq "Enabled") {
   Disable-NetAdapterBinding -Name $interfacealias -ComponentID ms_tcpip6}

if ($HostName) {
    rename-computer -newname $HostName -force -restart
}