## Mac Facts

This module is a dumping ground for all the Mac facts I've built for Facter.
Feel free to take a couple or file a Pull Request or two.  Some facts were
built in haste, some with malice, but all were useful for at least one or two
seconds in their lifetime...


## `lib/facter/interface_map.rb`

This file maps BSD interface names with 'Friendly' interface names a la:

    en0_name => 'Ethernet',
    en1_name => 'Wi-Fi',
    en2_name => 'FireWire',

## `lib/facter/mac_interfaces.rb`

This file returns a comma separated list of all 'Friendly' interface names a la:

    mac_interfaces => 'Bluetooth DUN,Bluetooth PAN,Display Ethernet,Ethernet,FireWire,Wi-Fi,iPhone USB'

## `lib/facter/proxy_enabled.rb`

This file returns a WHOLE SLEW of facts based on proxy information from all your Network Interfaces, a la:

    firewire_ftp_proxy_enabled => true
    firewire_ftp_proxy_port => 1234
    firewire_ftp_proxy_server => ftp.test.proxy
    firewire_web_proxy_enabled => true
    firewire_web_proxy_port => 8190
    firewire_web_proxy_server => web.test.proxy
    ethernet_auto_proxy_enabled => Yes
    ethernet_auto_proxy_url => auto.puppetlabs.com

## For more information

See the comments in the facts themselves (isn't the code documentation enough?)
