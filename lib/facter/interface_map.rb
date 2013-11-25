require 'facter/util/plist'

# This fact will parse through the interface plist at
# '/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist' and create
# a mapping of BSD interface names to 'Friendly' interface names that look like
# this:
#
#     en0_name => 'Ethernet',
#     en1_name => 'Wi-Fi',
#     en2_name => 'FireWire',
#     <...etc...>
#
# Facts will also be created for any active network interfaces that look like
# this:
#
#     en0_active => true,
#     en1_active => true,
#
# (Note that inactive interfaces will not have facts created, which is handy
# for conditional statements).
#
if Facter.value(:osfamily) == 'Darwin'
  interfaces = Plist::parse_xml(File.read('/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist'))
  interfaces['Interfaces'].each do |interface|
    bsd_name      = interface['BSD Name']
    friendly_name = interface['SCNetworkInterfaceInfo']['UserDefinedName']
    active        = interface['Active']
    Facter.add("#{bsd_name}_name") do
      setcode do
        friendly_name
      end
    end
    Facter.add("#{bsd_name}_active") do
      setcode do
        active
      end
    end
  end
end
