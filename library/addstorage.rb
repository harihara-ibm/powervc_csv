# Addstorage module is used for creating additional volumes and attaching to VMs
module Addstorage

  # Check the VM health status
  def check_server_health(filename)
    # Creating an array of VM names for which Volumes have to be added.
    @lpars_to_add_vols = []
    CSV.foreach(filename, headers: true) do |csvarr|
      @lpars_to_add_vols.push(csvarr['lpar_name'])
    end
    puts 'Checking the VM health for all VMs.'
    # Checking if the VM's health status is OK. We will stop processing if the VM's health status is anything other than OK.
    @lpars_to_add_vols.each do |lpar_name|
      get_resource_list('compute', 'servers', 'servers')
      @server_id = find_id(@resource_name_list, @resource_id_list, "#{lpar_name}")
      get_url('compute')
      server_rest = rest_get("#{@resource_url}/servers/#{@server_id}", @token_id)
      server_health = JSON.parse(server_rest)
      @server_health = server_health['server']['health_status']['health_value']
      if @server_health != 'OK'
        puts "The VM #{lpar_name}'s health is not OK. "
        puts "The VM's health must be OK for adding storage volumes."
        puts 'Fix the VM health and run the tool again.'
        puts 'Stopping processing here.'
        exit
      end
    end
    puts 'All VMs health status is OK'
  end

  # Creating and Attaching Volumes
  def add_storage_volume(filename)
    puts 'Starting to Create and attach additional volumes'
    # We will first create the Volumes.
    CSV.foreach(filename, headers: true) do |csvarr|
      @lpar_name = csvarr['lpar_name'].to_s
      num_of_disks = csvarr['num_of_disks'].to_i
      @volume_id_array = []
      num = 1
      until num > num_of_disks do
        disk_name = 'disk_name_'+num.to_s; disk_size = 'disk_size_'+num.to_s; storage_template = 'storage_template_'+num.to_s; multi_attach = 'multi_attach_'+num.to_s
        @volume_name = "#{csvarr[disk_name]}"
        @volume_size = "#{csvarr[disk_size]}"
        @volume_type = "#{csvarr[storage_template]}"
        @multi_attach = "#{csvarr[multi_attach]}"
        @volume_add_template = JSON.dump(
            {
              "volume": {
                  "size": "#{@volume_size}",
                  "name": "#{@volume_name}",
                  "volume_type": "#{@volume_type}",
                  "multiattach": "#{@multi_attach}"
            }
        })
        get_url('volume')
        puts "Creating the Volume #{@volume_name}"
        @volume = rest_post("#{@resource_url}/volumes", "#{@volume_add_template}", @token_id)
        @volume_id = JSON.parse(@volume)['volume']['id']
        @volume_id_array.push(@volume_id)
        num += 1
      end
      # Attach all volumes to the VM
      @volume_id_array.each do |volume_id|
        @attach_volume_template = JSON.dump(
        {
            "volumeAttachment": {
                "volumeId": "#{volume_id}"
            }
        })
        get_resource_list('compute', 'servers', 'servers')
        @server_id = find_id(@resource_name_list, @resource_id_list, "#{@lpar_name}")
        puts "Attaching Volume #{@volume_name} to VM #{@lpar_name}"
        @volume_attach = rest_post("#{@resource_url}/servers/#{@server_id}/os-volume_attachments", "#{@attach_volume_template}", @token_id)
        puts "Done"
      end
    end
  end
end
