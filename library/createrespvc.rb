# Createrespowervc module is called by the build action to deploy LPARs/VMs when spec_type is openstack
module Createrespowervc

  # Creates VM with Manual/Specified IP Address.
  def create_server_man_ip
    puts "Creating the VM #{@lpar_name} with Auto IP Address, and an Openstack template!"
  	@server_manip_template = JSON.dump(
    	{
      	  "server": {
          		"name": "#{@lpar_name}",
            	"imageRef": "#{@image_id}",
              "flavorRef": "#{@flavor_id}",
            	"availability_zone": "nova",
            	"networks": [{
        		  		"uuid": "#{@network_id}",
        		  		"fixed_ip": "#{@ip_address}"
        			}]
        	}
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@server_manip_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end

  # Creates VMs with Auto IP Address.
  def create_server_auto_ip
    puts "Creating the VM #{@lpar_name} with IP Address #{@ip_address} and an Openstack template!"
  	@server_autoip_template = JSON.dump(
    	{
            "server": {
            		"name": "#{@lpar_name}",
                "imageRef": "#{@image_id}",
                "flavorRef": "#{@flavor_id}",
                "availability_zone": "nova",
                "networks": [{
            				"uuid": "#{@network_id}"
            		}]
            }
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@server_autoip_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end

  # Creates VMs with Auto IP address, and additional volumes.
  def create_server_autoip_adddisk
    puts "Creating the VM #{@lpar_name} with Auto IP Address, and additional disk(s)!"
    create_volumes_from_file(@additional_disk_file)
    @server_autoip_adddisk_template = JSON.dump(
      {
            "server": {
            		"name": "#{@lpar_name}",
              	"imageRef": "#{@image_id}",
                "flavorRef": "#{@flavor_id}",
              	"availability_zone": "nova",
              	"networks": [{
          		  		"uuid": "#{@network_id}"
          			}],
                "block_device_mapping_v2": @block_device_array
          	}
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", @server_autoip_adddisk_template, @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end

  # Creates VMs with Manual/Specified IP Address, and additional volumes.
  def create_server_manip_adddisk
    puts "Creating the VM #{@lpar_name} with IP Address #{@ip_address} and additional disk(s)!"
    create_volumes_from_file(@additional_disk_file)
    @server_manip_adddisk_template = JSON.dump(
  	   {
    	  "server": {
        		"name": "#{@lpar_name}",
          	"imageRef": "#{@image_id}",
          	"flavorRef": "#{@flavor_id}",
          	"availability_zone": "nova",
          	"networks": [{
      		  		"uuid": "#{@network_id}",
      		  		"fixed_ip": "#{@ip_address}"
      			}],
            "block_device_mapping_v2": @block_device_array
        }
      })
    get_url('compute')
    @server = rest_post("#{@resource_url}/servers", "#{@server_manip_adddisk_template}", @token_id)
    @server_uuid = JSON.parse(@server)['server']['id']
    puts 'Done'
  end
end
