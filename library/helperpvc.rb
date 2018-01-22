# Helperpowervc module contains functions used by all other modules
module Helperpowervc

  # Gather all required inputs from the rc file
  def gather_inputs_from_rcfile
    begin
      File.foreach('powervcrc') do |line|
        @url = line.split('= ')[1].chomp if line =~ /^url/
        @user = line.split('= ')[1].chomp if line =~ /^user/
        @password = line.split('= ')[1].chomp if line =~ /^password/
        @project = line.split('= ')[1].chomp if line =~ /^project/
        @ssl_ca_file = line.split('= ')[1].chomp if line =~ /^ssl_ca_file/
      end
    rescue
      puts "Oops! Either we are unable to find the powervcrc file or the specified parameters are incorrect."
      puts "Please check the powervcrc file for required content and run the tool again!"
      exit
    end
  end

  # Initialize the action and resource variables
  def initialize_vars
    @action = ARGV[0].to_s
    @resource = ARGV[1].to_s
  end

  # Check if the resource (csv) file exists in the correct location
  def resource_file_exists(filename)
    unless File.exist?(filename)
      puts "The provided resource file #{filename} doesnt exist."
      puts "Please provide the correct file name and location."
      exit
    end
  end

  # Helper function to create a header, for printing.
  def header
    puts
  end

  # Helper function to create a footer, for printing.
  def footer
    puts "\n"
    150.times{ print '#' }
    puts "\n"
  end

  # Helper function to print Help message.
  def help_message(resource)

    case resource
    when /query|q\b/i 
      header
      puts %q( The query action accepts the below options for resource. 
            - vms | servers:                Managed Virtual Machines / LPARs
            - flavors | compute_templates:  All Compute Templates
            - networks:                     All Networks
            - volumes:                      Managed Storage volumes
            - storage_templates:            All Storate Templates
            - images:                       All Images
            - storage_providers:            Managed Storage Providers
            - scg:                          All Storage Connectivity Groups
            - projects:                     All Projects
            - fabrics:                      Managed Fabrics
            - host_groups:                  All Host Groups, along with Host details
            - all:                          All resources in the above list

      Examples:

          ./powervc_csv.rb query vms
          ./powervc_csv.rb query images 

        For more exmaples please refer to the Examples.txt file )

      footer
    when /build|b\b/i
      header
      puts %q( The build action accepts a CSV-formatted file as its resource.

      Examples:

          ./powervc_csv.rb build csv/lpar_build_sample.csv
          
          The column descriptions for the CSV file is available in the README.txt file. 

        For more exmaples please refer to the Examples.txt file)

      footer
    when /report|r\b/i
      header
      puts %q( The report action accepts the below options for resource. 
            - vms | servers:                Managed Virtual Machines / LPARs
            - flavors | compute_templates:  All Compute Templates
            - networks:                     All Networks
            - volumes:                      Managed Storage volumes
            - storage_templates:            All Storate Templates
            - storage_providers:            Managed Storage Providers
            - scg:                          All Storage Connectivity Groups
            - all:                          All resources in the above list

      Examples:

          ./powervc_csv.rb report vms
          ./powervc_csv.rb report images 

        The reports are created in the csv directory. 
        For more exmaples please refer to the Examples.txt file)
      footer

    when /delete|'d'\b/i
      header
      puts %q( The delete action accepts a comma-separated list of LPARs / VMs to be deleted.

      Examples:

          ./powervc_csv.rb delete lpar1,lpar2,lpar3,lpar4
          
        For more exmaples please refer to the Examples.txt file )
      footer

    when /as\b|add-storage/i
      header
      puts %q( The add-storage action accepts a CSV-formatted file as its resource.

      Examples:

          ./powervc_csv.rb add-storage csv/add_stor_sample.csv
          
          The column descriptions for the CSV file is available in the README.txt file. 

        For more exmaples please refer to the Examples.txt file )
      footer

    else
      header
      puts %q( ** Usage ** ver 1.0.3 **

        ruby powervc_csv.rb <action> <resource>
  		
  	    The program takes two arguments - action, resource

        <action>
          Specifies the action to be performed. 
          Only of the below list of actions can be specified. 
          The action argument is mandatory. 

          q | query:          Queries the specified resource type and displays the output on the screen

          r | report:         Create a CSV-formatted report for the specified resource
                              The output file will be created in the ./csv/ directory
                              The output file name is in the format - <resource>_<date&time>.csv

          b | build:          Builds VMs in PowerVC using the CSV-formatted file

          d | delete:         Deletes the list of VMs in PowerVC
                              A comma-separated list of VMs must can be provided as the resource

          as | add-storage:   Adds multiple Storage volumes to existing Virtual Machines in PowerVC
                              The volume specifications are provided using a CSV-formatted input file

          h | help:           Prints the tool usage message (which is what you are reading now :-)

          <resource> 
            Specifies the selection for the resource to perform the action on.
            The available options for the resource argument are based on the selected action. 

            You may run help command to get more information for accepted resource options for each action. 
            For example: ./powervc_csv.rb help build

        Examples:
        
        Please refer to EXAMPLES.txt for more examples with screen output. )
      footer
    end
  end

  # Helper funtion Preparing to print using the Terminal Table gem.
  def print_table(header_array, table_array)
    table = Terminal::Table.new :headings => header_array, :rows => table_array
    puts table
  end

  # Helper function to print arrays and headers to a csv file.
  def csv_array(array, csv)
    array.each do |elem|
      csv << elem
    end
  end

  # Helper function to find ID of a specific resource.
  def find_id(name_array, id_array, name)
    index = name_array.find_index(name).to_i
    @resource_id = id_array[index]
  end

  # Helper function to create the additional volumes as requested during VM creation.
  def create_volumes_from_file(filename)
    CSV.foreach(filename,headers: true) do |csvarr|
      if @lpar_name == csvarr['lpar_name'].to_s
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
          @volume = rest_post("#{@resource_url}/volumes", "#{@volume_add_template}", @token_id)
          @volume_id = JSON.parse(@volume)['volume']['id']
          @volume_id_array.push(@volume_id)
          num += 1
        end
        @block_device_array = []
        @volume_id_array.each do |volid|
          add_storage_lmb(volid)
        end
      end
    end
  end

  # Helper function to create the Template to add the volumes as part of VM creation.
  def add_storage_lmb(uuid)
    @block_device_hash = {"boot_index" => "-1", "destination_type" => "volume", "source_type" => "volume", "uuid" => "#{uuid}"}
    @block_device_array.push(@block_device_hash)
  end

  # Helper function to do REST GET calls.
  def rest_get(url, token_id, ssl_ca_file = @ssl_ca_file)
    begin
      RestClient::Request.execute(method: :get, url: "#{url}", headers: {'accept': 'application/json', 'x-auth-token': token_id}, :ssl_ca_file => "#{ssl_ca_file}")
    rescue
      RestClient::Request.execute(method: :get, url: "#{url}", headers: {'accept': 'application/json', 'x-auth-token': token_id}, verify_ssl: false)
    end
  end

  # Helper function to do REST POST calls.
  def rest_post(url, payload, token_id, ssl_ca_file = @ssl_ca_file)
    begin
      RestClient::Request.execute(method: :post, url: "#{url}", payload: "#{payload}", headers: {'accept': 'application/json', 'content-type': 'application/json', 'x-auth-token': token_id}, :ssl_ca_file => "#{ssl_ca_file}")
    rescue
      RestClient::Request.execute(method: :post, url: "#{url}", payload: "#{payload}", headers: {'accept': 'application/json', 'content-type': 'application/json', 'x-auth-token': token_id}, verify_ssl: false)
    end
  end

  # Helper function to do REST DELETE calls.
  def rest_delete(url, token_id, ssl_ca_file = @ssl_ca_file)
    begin
      RestClient::Request.execute(method: :delete, url: "#{url}", headers: {'accept': 'application/json', 'x-auth-token': token_id}, :ssl_ca_file => "#{ssl_ca_file}")
    rescue
      RestClient::Request.execute(method: :delete, url: "#{url}", headers: {'accept': 'application/json', 'x-auth-token': token_id}, verify_ssl: false)
    end
  end
end
