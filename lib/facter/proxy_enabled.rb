# This is a series of custom Facter facts derived from proxy information pulled
# from all Network Interfaces on OS X.  Custom facts look like the following:
#
#     firewire_ftp_proxy_enabled => true
#     firewire_ftp_proxy_port => 1234
#     firewire_ftp_proxy_server => ftp.test.proxy
#     firewire_web_proxy_enabled => true
#     firewire_web_proxy_port => 8190
#     firewire_web_proxy_server => web.test.proxy
#     ethernet_auto_proxy_enabled => Yes
#     ethernet_auto_proxy_url => auto.puppetlabs.com
#
# The facts are in the format of:
#     {interface name}_{proxy type}_{data item}
#
# The data item indicates whether the proxy is enabled or what the
# server/port/url value is for that proxy.  Proxy enabled values will ONLY show
# up if the proxy is enabled, which makes the facts handy for conditional
# information in Puppet.  It also makes for excellent live inventory data
# through MCollective or Live Management in Puppet Enterprise.  

if Facter.value(:osfamily) == 'Darwin'
  # This is the list of all proxies whose data output is identical (see the
  # case statement below).  You can also limit the fact data you receive by
  # scoping down this array (i.e. if you don't care about gopher or socks proxy
  # data, you can remove them from the array and the facts won't check for that
  # data from your Network Interfaces).
  @proxies = [
    'web',
    'gopher',
    'secureweb',
    'ftp',
    'streaming',
    'socks'
  ]

  # Oh yeah - we rely on the 'mac_interfaces' custom fact that's also in this
  # module...
  Facter.value(:mac_interfaces).split(',').each do |iface|
    @proxies.each do |proxy|
      # Set 'output' equal to the results of the networksetup command
      # We have two lookups here because auto proxy data is in a different
      # format from the rest of the proxy data
      output      = Facter::Util::Resolution.exec("networksetup -get#{proxy}proxy '#{iface}'")
      auto_output = Facter::Util::Resolution.exec("networksetup -getautoproxyurl '#{iface}'")

      # Initialize variables
      enabled_value, server_value, port_value, authenticated_value, auto_url, auto_enabled = nil

      # Substitute spaces for underscores
      iface_nospaces = iface.gsub(' ','_')

      # Split the output array and iterate through it, setting values for all
      # appropriate proxy facts
      output.split("\n").each do |output_item|
        item_array = output_item.split(':')
        case item_array.first
        when 'Enabled'
          enabled_value = item_array.last.strip
        when 'Server'
          server_value = item_array.last.strip
        when 'Port'
          port_value = item_array.last.strip
        when 'Authenticated Proxy Enabled'
          authenticated_value = item_array.last.strip
        end
      end

      # As I said above, auto proxy data is formatted differently, so we need
      # to account for that with a different case statement.
      auto_output.split("\n").each do |auto_item|
        auto_item_array = auto_item.split(':')
        case auto_item_array.first
        when 'URL'
          auto_url = auto_item_array.last.strip
        when 'Enabled'
          auto_enabled = auto_item_array.last.strip
        end
      end

      # These are all the possible values coming from 'networksetup' that could
      # be negative
      negative_values = ['0', 'No', nil, '(null)']

      # Actually set fact values here. If the value equals one of the values in
      # the negative_values array, then just make the fact nil so it doesn't
      # report
      Facter.add("#{iface_nospaces}_#{proxy}_proxy_enabled") do
        setcode do
          negative_values.include?(enabled_value) ? nil : 'true'
        end
      end
      Facter.add("#{iface_nospaces}_#{proxy}_proxy_authenticated") do
        setcode do
          negative_values.include?(authenticated_value) ? nil : 'true'
        end
      end
      Facter.add("#{iface_nospaces}_#{proxy}_proxy_server") do
        setcode do
          negative_values.include?(server_value) ? nil : server_value
        end
      end
      Facter.add("#{iface_nospaces}_#{proxy}_proxy_port") do
        setcode do
          negative_values.include?(port_value) ? nil : port_value
        end
      end
      Facter.add("#{iface_nospaces}_auto_proxy_url") do
        setcode do
          negative_values.include?(auto_url) ? nil : auto_url
        end
      end
      Facter.add("#{iface_nospaces}_auto_proxy_enabled") do
        setcode do
          negative_values.include?(auto_enabled) ? nil : auto_enabled
        end
      end
    end
  end
end

