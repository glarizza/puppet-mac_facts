# This is a custom 'mac_interfaces' fact that will output a comma-separated
# list of 'Friendly' interface names that looks like:
#
#     mac_interfaces => 'Bluetooth DUN,Bluetooth PAN,Display Ethernet,Ethernet,FireWire,Wi-Fi,iPhone USB'
#
# (Note that the interfaces are appropriately capitalized and spaces are left
# intact)
#
Facter.add(:mac_interfaces) do
  confine :osfamily => :darwin
  setcode do
    interfaces_string   = Facter::Util::Resolution.exec('networksetup -listallnetworkservices')
    array_of_interfaces = interfaces_string.split("\n").sort!

    # Remove the annoying "An asterisk (*) denotes that a network service is
    # disabled." line
    array_of_interfaces.shift

    # Return a comma-separated list of friendly interfaces
    array_of_interfaces.join(',')
  end
end
