# Buildrespowervc module is used by the build action to deploy LPARs/VMs
module Buildrespowervc
  require_relative 'createrespvc'
  require_relative 'pvmcreaterespvc'
  include Createrespowervc
  include PvmCreaterespowervc

  # Create VMs
  def build_server(filename)
    @lpar_name_array = []
    @lpar_id_array = []
    # Read each line of CSV file, intialize the required Variables.
    CSV.foreach(filename, headers: true) do |csvarr| 
      @spec_type = csvarr['spec_type'].to_s
      @lpar_name = csvarr['lpar_name'].to_s
      @lpar_name_array.push(@lpar_name)
      @image = csvarr['image'].to_s
      @flavor = csvarr['compute_template'].to_s
      @additional_disk_file = csvarr['additional_disk_file'].to_s
      @ip_address = csvarr['ip_address'].to_s
      @network_name = csvarr['network_name'].to_s
      @desired_mem = csvarr['desired_mem'].to_s
      @desired_vcpu = csvarr['desired_vcpu'].to_s
      @desired_ec = csvarr['desired_ec'].to_s
      @min_ec = csvarr['min_ec'].to_s
      @max_ec = csvarr['max_ec'].to_s
      @min_vcpu = csvarr['min_vcpu'].to_s
      @max_vcpu = csvarr['max_vcpu'].to_s
      @min_mem = csvarr['min_mem'].to_s
      @max_mem = csvarr['max_mem'].to_s
      @proc_comp_mode = csvarr['proc_comp_mode'].to_s
      @stor_conn_grp = csvarr['stor_conn_grp'].to_s
      @srr_cap = csvarr['srr_capability'].to_s
      @shared_weight = csvarr['shared_weight'].to_s
      @shared_proc_pool_name = csvarr['shared_proc_pool_name'].to_s
      @avail_priority = csvarr['availability_priority'].to_s
      @lpars_requires_add_disks = []
      # Create an array with the VM names for which additional storage volumes are required.
      unless @additional_disk_file == ''
        resource_file_exists(@additional_disk_file)
        CSV.foreach(@additional_disk_file, headers: true) do |arr|
          @lpars_requires_add_disks.push(arr['lpar_name'])
        end
      end
      # Call openstack API function calls if the spec type is openstack
      if @spec_type == 'openstack'
        get_resource_list('image', 'v2/images', 'images')
        @image_id = find_id(@resource_name_list, @resource_id_list, @image)
        get_resource_list('compute', 'flavors', 'flavors')
        @flavor_id = find_id(@resource_name_list, @resource_id_list, @flavor)
        get_resource_list('network', 'v2.0/networks', 'networks')
        @network_id = find_id(@resource_name_list, @resource_id_list, @network_name)
        if @ip_address == 'auto' && !@lpars_requires_add_disks.include?(@lpar_name)
          create_server_auto_ip
          @lpar_id_array.push(@server_uuid)
        elsif @ip_address != 'auto' && !@lpars_requires_add_disks.include?(@lpar_name)
          create_server_man_ip
          @lpar_id_array.push(@server_uuid)
        elsif @ip_address == 'auto' && @lpars_requires_add_disks.include?(@lpar_name)    
          create_server_autoip_adddisk
          @lpar_id_array.push(@server_uuid)
        elsif @ip_address != 'auto' && @lpars_requires_add_disks.include?(@lpar_name)
          create_server_manip_adddisk
          @lpar_id_array.push(@server_uuid)
        else
          puts 'One of the specified parameters in the CSV file is invalid.'
        end
      # Call PowerVC Extended API function calls if the spec type is powervm
      elsif @spec_type == 'powervm'
        get_resource_list('image', 'v2/images', 'images')
        @image_id = find_id(@resource_name_list, @resource_id_list, @image)
        get_resource_list('network', 'v2.0/networks', 'networks')
        @network_id = find_id(@resource_name_list, @resource_id_list, @network_name)
        if @ip_address == 'auto' && !@lpars_requires_add_disks.include?(@lpar_name)
          pvm_create_server_auto_ip
          @lpar_id_array.push(@server_uuid)
        elsif @ip_address != 'auto' && !@lpars_requires_add_disks.include?(@lpar_name)
          pvm_create_server_man_ip
          @lpar_id_array.push(@server_uuid)
        elsif @ip_address == 'auto' && @lpars_requires_add_disks.include?(@lpar_name)
          pvm_create_server_autoip_adddisk
          @lpar_id_array.push(@server_uuid)
        elsif @ip_address != 'auto' && @lpars_requires_add_disks.include?(@lpar_name)
          pvm_create_server_manip_adddisk
          @lpar_id_array.push(@server_uuid)
        else
          puts 'One of the specified parameters in the CSV file is invalid.'
        end
      else
        puts 'The specified value for Deploy_Type in the CSV file is invalid.'
      end
    end
    puts 'Finished processing VM builds.'
  end

  # Check the status of deployed VMs
  def check_server_status
    @server_status_array = Array.new(@lpar_id_array)
    until @server_status_array.empty?
      @server_status_array.each do |lpar|
        lpar_name_index = @server_status_array.find_index(lpar)
        @lpar_name_deployed = @lpar_name_array[lpar_name_index]
        puts "Checking status of #{@lpar_name_deployed}"
        get_url('compute')
        @server_status = rest_get("#{@resource_url}/servers/#{lpar}", @token_id)
        @server_id_status = JSON.parse(@server_status)['server']['status']
        puts "Status of #{@lpar_name_deployed} is #{@server_id_status}"
        if @server_id_status =~ /ACTIVE/ || @server_id_status =~ /ERROR/
          @server_status_array.delete(lpar)
        else
          puts 'Waiting for 20 seconds'
          sleep 20
        end
      end
    end
    puts 'All LPARs have been deployed, proceed to login to the LPARs.'
  end

  # Print details of the VMs successfully deployed and they are in Active state
  def print_server_details
    @check_server_status_array = Array.new(@lpar_id_array)
    get_url('compute')
    @check_server_status_array.each do |lpar|
      @server_status_print = rest_get("#{@resource_url}/servers/#{lpar}", @token_id)
      @server_status = JSON.parse(@server_status_print)['server']
      @server_name_print = @server_status['name']
      @server_addresses = JSON.parse(@server_status_print)['server']['addresses']
      begin
        @server_ip4address = @server_addresses.values[0][0]['addr']
        puts "LPAR Name: #{@server_name_print}, IP Address: #{@server_ip4address}"
      rescue
        puts "Deploy of LPAR Name #{@server_name_print} has resulted in error. Please login to PowerVC GUI to check further."
      end
    end
  end
end
