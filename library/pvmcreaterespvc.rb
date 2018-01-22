# PvmCreaterespowervc module is called by the build action to deploy LPARs/VMs when spec_type is powervm
module PvmCreaterespowervc

  # Defining specifications for PowerVC Extended APIs for HMC style LPAR definitions.
  def extra_specs
    @extra_specs_hash = {
      "powervm:proc_units": @desired_ec,
      "powervm:min_proc_units": @min_ec,
      "powervm:max_proc_units": @max_ec,
      "powervm:min_vcpu": @min_vcpu,
      "powervm:max_vcpu": @max_vcpu,
      "powervm:min_mem": @min_mem,
      "powervm:max_mem": @max_mem,
      "powervm:processor_compatibility": @proc_comp_mode,
      "powervm:storage_connectivity_group": @stor_conn_id,
      "powervm:srr_capability": @srr_cap,
      "powervm:availability_priority": @avail_priority,
      "powervm:shared_weight": @shared_weight,
      "powervm:shared_proc_pool_name": @shared_proc_pool_name }
  end

  # Function to get Storage Connectivity Group based on the Image to be deployed.
  def find_stor_conn_id(stor_conn_grp)
    get_resource_list('compute', 'storage-connectivity-groups', 'storage_connectivity_groups', name = 'display_name', id = 'id')
    @stor_conn_id = find_id(@resource_name_list, @resource_id_list, "#{stor_conn_grp}")
  end

  # Create VM with Manual / Specific IP address.
  def pvm_create_server_man_ip
    puts "Creating the VM #{@lpar_name} with IP Address #{@ip_address}, and with PowerVM specs!"
    find_stor_conn_id(@stor_conn_grp)
    extra_specs
  	@pvm_manip_template = JSON.dump(
    	{
      	  "server": {
          		"name": @lpar_name,
            	"imageRef": @image_id,
              "flavor": {
                  "ram": @desired_mem,
                  "vcpus": @desired_vcpu,
                  "disk": "1",
                  "extra_specs": @extra_specs_hash
              },
            	"availability_zone": "nova",
            	"networks": [{
        		  		"uuid": @network_id,
        		  		"fixed_ip": @ip_address
        			}]
        	}
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@pvm_manip_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end

  # Create VMs with Auto IP address.
  def pvm_create_server_auto_ip
    puts "Creating the VM #{@lpar_name} with Auto IP Address, and with PowerVM specs!"
    find_stor_conn_id(@stor_conn_grp)
    extra_specs
  	@pvm_autoip_template = JSON.dump(
    	{
            "server": {
            		"name": @lpar_name,
                "imageRef": @image_id,
                "flavor": {
                    "ram": @desired_mem,
                    "vcpus": @desired_vcpu,
                    "disk": "1",
                    "extra_specs": @extra_specs_hash
                },
                "availability_zone": "nova",
                "networks": [{
            				"uuid": @network_id
            		}]
            }
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@pvm_autoip_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end

  # Create VMs with Auto IP Address and additional disks.
  def pvm_create_server_autoip_adddisk
    puts "Creating the VM #{@lpar_name} with Auto IP Address and additional disk(s), with PowerVM specs!"
    find_stor_conn_id(@stor_conn_grp)
    extra_specs
    create_volumes_from_file(@additional_disk_file)
    @pvm_autoip_adddisk_template = JSON.dump(
      {
            "server": {
            		"name": @lpar_name,
              	"imageRef": @image_id,
                "flavor": {
                    "ram": @desired_mem,
                    "vcpus": @desired_vcpu,
                    "disk": "1",
                    "extra_specs": @extra_specs_hash
                },
              	"availability_zone": "nova",
              	"networks": [{
          		  		"uuid": @network_id
          			}],
                "block_device_mapping_v2": @block_device_array
          	}
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@pvm_autoip_adddisk_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end

  # Create VMs with Manual / Specific IP Address and additional disks.
  def pvm_create_server_manip_adddisk
    puts "Creating the VM #{@lpar_name} with Manual IP Address and additional disk(s), with PowerVM specs!"
    find_stor_conn_id(@stor_conn_grp)
    extra_specs
    create_volumes_from_file(@additional_disk_file)
    @pvm_manip_adddisk_template = JSON.dump(
  	{
    	  "server": {
        		"name": @lpar_name,
          	"imageRef": @image_id,
            "flavor": {
                "ram": @desired_mem,
                "vcpus": @desired_vcpu,
                "disk": "1",
                "extra_specs": @extra_specs_hash
            },
          	"availability_zone": "nova",
          	"networks": [{
      		  		"uuid": @network_id,
      		  		"fixed_ip": @ip_address
      			}],
            "block_device_mapping_v2": @block_device_array
        }
    })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@pvm_manip_adddisk_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end
end
