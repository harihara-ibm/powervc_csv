# Reportrespowervc module is by the report action
module Reportrespowervc

  # Main function to create reports based on the requested resource.
  def report_main(resource)
    dfr = DateTime.now
    output_dir = 'reports'
    unless Dir.exist?(output_dir)
      puts "The reports directory doesn't exist. So, Creating reports directory now"
      Dir.mkdir(output_dir, 0755)
    end
    repfilename = "#{output_dir}/#{resource}_"+dfr.strftime('%F-%H-%M-%S')+'.csv'
    puts "The output filename is #{repfilename}"
    case resource
    when /vms?|servers?/i
      server_report_csv(repfilename)
    when /flavors?|compute_templates?/i
      flavor_report_csv(repfilename)
    when /networks?|net/i
      network_report_csv(repfilename)
    when /volumes?|disks?/i
      volume_report_csv(repfilename)
    when /storage_templates?/i
      volume_type_report_csv(repfilename)
    when /storage_providers?|storage/i
      stg_provider_report_csv(repfilename)
    when /scg/i
      scg_report_csv(repfilename)
    when /all/i
      server_report_csv(repfilename)
      flavor_report_csv(repfilename)
      network_report_csv(repfilename)
      volume_report_csv(repfilename)
      volume_type_report_csv(repfilename)
      stg_provider_report_csv(repfilename)
      scg_report_csv(repfilename)
    else
      help = HelpMessage.new
      help.help_message(@resource)
    end
  end

  # Creates the Server (VMs) report.
  def server_report
    get_resource_list('compute', 'servers', 'servers')
    @server_csv_array = []
    @server_print_array = []
    @resource_id_list.each do |serverid|
      server = rest_get("#{@resource_url}/servers/#{serverid}", @token_id)
      server_array = JSON.parse(server)['server']
      server_name = server_array['name']
      server_lpar_name = server_array['OS-EXT-SRV-ATTR:instance_name']
      server_lpar_state = server_array['OS-EXT-STS:vm_state']
      server_state = server_array['status']
      server_health = server_array['health_status']['health_value']
      server_host = server_array['OS-EXT-SRV-ATTR:host']
      server_addresses = JSON.parse(server)['server']['addresses']
      @server_ipaddress = ''
      unless server_addresses.empty? || server_state != 'ACTIVE'
        @server_ipaddress = server_addresses.values[0][0]['addr']
      end
      server_flavor = server_array['flavor.original_name']
      server_cpus = server_array['cpus']
      server_memory = server_array['memory_mb']
      server_cpu_util = server_array['cpu_utilization']
      server_cpu_mode = server_array['vcpu_mode']
      server_os = server_array['operating_system']
      server_cpu_pool = server_array['shared_proc_pool_name']
      server_cpu_share_weight = server_array['shared_weight']
      server_compat_mode = server_array['desired_compatibility_mode']
      @server_csv_array << [server_name, server_lpar_name, server_lpar_state, server_state, server_host, server_health, @server_ipaddress, server_flavor, server_cpus, \
                              server_memory, server_cpu_util, server_cpu_mode, server_os, server_cpu_pool, server_cpu_share_weight, server_compat_mode]
      @server_print_headers = %w(Host_Name LPAR_Name LPAR_State OS_Status Machine_Name LPAR_Health IPaddress Template CPU Memory CPU_Util CPU_Mode CPU_Pool Share_Weight)
      @server_print_array << [server_name, server_lpar_name, server_lpar_state, server_state, server_host, server_health, @server_ipaddress, server_flavor, server_cpus, \
                              server_memory, server_cpu_util, server_cpu_mode, server_cpu_pool, server_cpu_share_weight]
    end
  end

  # Creates the Flavors report.
  def flavor_report
    get_resource_list('compute', 'flavors', 'flavors')
    @flavor_print_array = []
    @resource_id_list.each do |flavorid|
      flavor = rest_get("#{@resource_url}/flavors/#{flavorid}", @token_id)
      flavor_extra = rest_get("#{@resource_url}/flavors/#{flavorid}/os-extra_specs", @token_id)
      flavor_array = JSON.parse(flavor)['flavor']
      flavor_extra_array = JSON.parse(flavor_extra)['extra_specs']
      flavor_name = flavor_array['name']
      flavor_vcpu = flavor_array['vcpus']
      flavor_mem = flavor_array['ram']
      flavor_min_vcpu = flavor_extra_array['powervm:min_vcpu']
      flavor_max_vcpu = flavor_extra_array['powervm:max_vcpu']
      flavor_min_ec = flavor_extra_array['powervm:min_proc_units']
      flavor_des_ec = flavor_extra_array['powervm:proc_units']
      flavor_max_ec = flavor_extra_array['powervm:max_proc_units']
      flavor_dec_cpu = flavor_extra_array['powervm:dedicated_proc']
      flavor_min_mem = flavor_extra_array['powervm:min_mem']
      flavor_max_mem = flavor_extra_array['powervm:max_mem']
      flavor_proc_compatibility = flavor_extra_array['powervm:processor_compatibility']
      flavor_cpu_pool = flavor_extra_array['powervm:shared_proc_pool_name']
      flavor_cpu_weight = flavor_extra_array['powervm:shared_weight']
      flavor_srr_capability = flavor_extra_array['powervm:srr_capability']
      @flavor_print_headers = %w(Template_Name VCPU Memory Min_VCPU Max_VCPU Min_EC Desired_EC Max_EC Dedicated_CPU Min_Mem Max_Mem Comp_Mode Pool_Name CPU_Weight SRR)
      @flavor_print_array << [flavor_name, flavor_vcpu, flavor_mem, flavor_min_vcpu, flavor_max_vcpu, flavor_min_ec, flavor_des_ec, flavor_max_ec, flavor_dec_cpu, flavor_min_mem, \
                            flavor_max_mem, flavor_proc_compatibility, flavor_cpu_pool, flavor_cpu_weight, flavor_srr_capability]
    end
  end

  # Creates the Networks report.
  def network_report
    get_resource_list('network', 'v2.0/networks', 'networks')
    @network_csv_array = []
    @network_print_array = []
    @resource_id_list.each do |networkid|
      network = rest_get("#{@resource_url}/v2.0/networks/#{networkid}", @token_id)
      network_array = JSON.parse(network)['network']
      network_name = network_array['name']
      network_status = network_array['status']
      network_vlanid = network_array['provider:segmentation_id']
      network_physnet = network_array['provider:physical_network']
      network_mtu = network_array['mtu']
      subnet_id = network_array['subnets']
      unless subnet_id.empty?
        subnet_id.each do |subnetid|
          subnet_rest = rest_get("#{@resource_url}/v2.0/subnets/#{subnetid}", @token_id)
          subnet_array = JSON.parse(subnet_rest)['subnet']
          @subnet_enable_dhcp = subnet_array['enable_dhcp']
          @subnet_dns_server = subnet_array['dns_nameservers']
          @subnet_startip = subnet_array['allocation_pools'][0]['start']
          @subnet_endip = subnet_array['allocation_pools'][0]['end']
          @subnet_gateway = subnet_array['gateway_ip']
          @subnet_cidr = subnet_array['cidr']
        end
      end
      @network_csv_array << [network_name, network_status, network_vlanid, network_physnet, network_mtu, @subnet_enable_dhcp, @subnet_dns_server, @subnet_startip, @subnet_endip, \
                              @subnet_gateway, @subnet_cidr]
      @network_print_headers = %w(Network_Name Network_VLANid Network_MTU Network_enable_dhcp Network_DNS_Servers Network_Start_IP Network_End_IP Network_Gateway Network_CIDR)
      @network_print_array << [network_name, network_vlanid, network_mtu, @subnet_enable_dhcp, @subnet_dns_server, @subnet_startip, @subnet_endip, @subnet_gateway, @subnet_cidr]
    end
  end

  # Creates the Volumes report.
  def volume_report
    get_resource_list('volume', 'volumes', 'volumes')
    @volume_csv_array = []
    @resource_id_list.each do |volumeid|
      volume = rest_get("#{@resource_url}/volumes/#{volumeid}", @token_id)
      volume_array = JSON.parse(volume)['volume']
      volume_name = volume_array['name']
      volume_status = volume_array['status']
      volume_template = volume_array['volume_type']
      volume_size = volume_array['size']
      @volume_csv_headers = %w(Volume_Name Volume_Status Storage_Template Volume_Size)
      @volume_csv_array << [volume_name, volume_status, volume_template, volume_size]
    end
  end

  # Creates the Storage Template Reports.
  def volume_type_report
    @volume_type_csv_array = []
    get_resource_list('volume', 'types', 'volume_types')
    @resource_id_list.each do |voltypeid|
      volume_type = rest_get("#{@resource_url}/types/#{voltypeid}", @token_id)
      volume_type_array = JSON.parse(volume_type)['volume_type']
      volume_type_name = volume_type_array['name']
      volume_type_drivers = volume_type_array['extra_specs']
      volume_type_unit_type = volume_type_drivers['drivers:logical_unit_type']
      volume_type_prov_type = volume_type_drivers['drivers:provision_type']
      @volume_type_csv_headers = %w(Storage_Template_Name Storage_Template_Type Storage_Template_Prov_Type)
      @volume_type_csv_array << [volume_type_name, volume_type_unit_type, volume_type_prov_type+'-provisioning']
    end
  end

  # Creates the Storage Providers report.
  def stg_provider_report
    @stg_provider_csv_array = []
    get_storage_providers
    @stg_providers_id_list.each do |stgprovider|
      stg_provider = rest_get("#{@volume_url}/storage-providers/#{stgprovider}", @token_id)
      stg_provider_array = JSON.parse(stg_provider)['storage_provider']
      stg_provider_name = stg_provider_array['service']['host_display_name']
      stg_provider_type = stg_provider_array['backend_type']
      stg_provider_health = stg_provider_array['health_status']['health_value']
      stg_provider_tot_cap = stg_provider_array['total_capacity_gb']
      stg_provider_free_cap = stg_provider_array['free_capacity_gb']
      @stg_provider_csv_headers = %w(Storage_Provider_Name Storage_Provider_Type Storage_Provider_Health Storage_Provider_Total_Cap Storage_Provider_Free_Cap)
      @stg_provider_csv_array << [stg_provider_name, stg_provider_type, stg_provider_health, stg_provider_tot_cap, stg_provider_free_cap]
    end
  end

  # Creates the SCG report.
  def scg_report
    @scg_csv_array = []
    get_resource_list('compute', 'storage-connectivity-groups', 'storage_connectivity_groups', name = 'display_name', id = 'id')
    @resource_id_list.each do |scgid|
      scg = rest_get("#{@resource_url}/storage-connectivity-groups/#{scgid}", @token_id)
      scg_array = JSON.parse(scg)['storage_connectivity_group']
      scg_name = scg_array['display_name']
      scg_auto_add_vios = scg_array['auto_add_vios']
      scg_fc_storage_access = scg_array['fc_storage_access']
      scg_ports_per_fabric_npiv = scg_array['ports_per_fabric_npiv']
      @scg_host_list = []
      @scg_host_array = scg_array['host_list']
      @scg_host_array.each do |host|
        @scg_host_list.push(host['name'])
      end
      @scg_vios_array = scg_array['host_list'][0]['vios_list']
      @scg_vios_names = []
      @scg_vios_array.each do |vios|
        @scg_vios_names.push(vios['name'])
      end
      @scg_csv_headers = %w(SCG_Name SCG_Auto_Add_VIOs SCG_FC_Storage_Access SCG_Ports_per_Fabric SCG_Host_List SCG_VIOs_List)
      @scg_csv_array << [scg_name, scg_auto_add_vios, scg_fc_storage_access, scg_ports_per_fabric_npiv, @scg_host_list, @scg_vios_names]
    end
  end

  # Print the VM report to the CSV output file.
  def server_report_csv(filename)
    puts 'Creating the VMs report'
    CSV.open("#{filename}", 'w') do |csv|
      csv << %w(VM_List)
      csv << %w(Host_Name LPAR_Name LPAR_State OS_Status LPAR_Health Machine_Name VM_IPaddress VM_Flavor VM_CPU VM_Memory VM_CPU_Utilization VM_CPU_Mode VM_OS VM_CPU_Pool \
                VM_Share_Weight VM_Proc_Compatibility_Mode)
      server_report
      csv_array(@server_csv_array, csv)
    end
    puts 'Done'
  end

  # Print the Flavors report to the CSV output file.
  def flavor_report_csv(filename)
    puts 'Creating the Flavors report'
    CSV.open("#{filename}", 'ab') do |csv|
      csv << ["\n"]
      csv << %w(Compute_Template_List)
      csv << %w(Template_Name VCPU Memory Min_VCPU Max_VCPU Min_EC Desired_EC Max_EC Dedicated_CPU Min_Mem Max_Mem Proc_Compatibility_Mode CPU_Pool_Name Shared_CPU_Weight SRR_Capability)
      flavor_report
      csv_array(@flavor_print_array, csv)
    end
    puts 'Done'
  end

  # Print the Networks report to the CSV output file.
  def network_report_csv(filename)
    puts 'Creating the Networks report'
    CSV.open("#{filename}", 'ab') do |csv|
      csv << ["\n"]
      csv << %w(Network_List)
      csv << %w(Network_Name Network_Status Network_VLANid Network_Phys_Net Network_MTU Network_enable_dhcp Network_DNS_Servers Network_Start_IP Network_End_IP Network_Gateway Network_CIDR)
      network_report
      csv_array(@network_csv_array, csv)
    end
    puts 'Done'
  end

  # Print the Volumes report to the CSV output file.
  def volume_report_csv(filename)
    puts 'Creating the Volumes report'
    CSV.open("#{filename}", 'ab') do |csv|
      csv << ["\n"]
      csv << %w(Volume_List)
      csv << %w(Volume_Name Volume_Status Storage_Template Volume_Size)
      volume_report
      csv_array(@volume_csv_array, csv)
    end
    puts 'Done'
  end

  # Print the Storage Templates report to the CSV output file.
  def volume_type_report_csv(filename)
    puts 'Creating the Storage Template report'
    CSV.open("#{filename}", 'ab') do |csv|
      csv << ["\n"]
      csv << %w(Storage_Template_List)
      csv << %w(Storage_Template_Name Storage_Template_Type Storage_Template_Prov_Type)
      volume_type_report
      csv_array(@volume_type_csv_array, csv)
    end
    puts 'Done'
  end

  # Print the Storage Providers report to the CSV output file.
  def stg_provider_report_csv(filename)
    puts 'Creating the Storage Providers report'
    CSV.open("#{filename}", 'ab') do |csv|
      csv << ["\n"]
      csv << %w(Storage_Providers_List)
      csv << %w(Storage_Provider_Name Storage_Provider_Type Storage_Provider_Health Storage_Provider_Total_Cap Storage_Provider_Free_Cap)
      stg_provider_report
      csv_array(@stg_provider_csv_array, csv)
    end
    puts 'Done'
  end

  # Print the SCG report to the CSV output file.
  def scg_report_csv(filename)
    puts 'Creating the Storage Connectivity Groups report'
    CSV.open("#{filename}", 'ab') do |csv|
      csv << ["\n"]
      csv << %w(Storage_Connectivity_Groups_List)
      csv << %w(SCG_Name SCG_Auto_Add_VIOs SCG_FC_Storage_Access SCG_Ports_per_Fabric SCG_Host_List SCG_VIOs_List)
      scg_report
      csv_array(@scg_csv_array, csv)
    end
    puts 'Done'
  end
end
