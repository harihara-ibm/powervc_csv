# Queryrespowervc module is used by the query action
module Queryrespowervc

  # Main function to call other functions based on resource to be queried.
  def query_main(resource)
    case resource
    when /vms?|servers?/i
      query_server_list
      report_server_list
    when /host_groups?/i
      query_host_group_list
    when /images?/i
      query_image_scg_list
    when /flavors?|compute_templates?/i
      query_flavor_list
      report_flavor_list
    when /networks?|net/i
      query_network_list
      report_network_list
    when /volumes?|disks?/i
      query_volume_list
      report_volume_list
    when /storage_templates?/i
      query_volume_type_list
      report_volume_type_list
    when /projects?/i
      query_project_list
    when /storage_providers?|storage/i
      query_storage_providers
      report_stg_provider_list
    when /fabrics?/i
      query_fabrics_list
    when /scg/i
      query_scg_list
      report_scg_list
    when /all/i
      query_server_list
      query_host_group_list
      query_image_list
      query_flavor_list
      query_network_list
      query_volume_list
      query_volume_type_list
      query_project_list
      query_storage_providers
      query_fabrics_list
      query_scg_list
    else
      help = PowerVCcsv::HelpMessage.new
      help.help_message(@resource)
    end
  end

  # Queries and prints the VMs list.
  def query_server_list
    get_resource_list('compute', 'servers', 'servers')
    puts 'The list of VMs in this PowerVC cloud are:'
    headers = ['VMs']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and prints the Flavors list.
  def query_flavor_list
    get_resource_list('compute', 'flavors', 'flavors')
    puts 'The list of Compute Templates in this PowerVC cloud are:'
    headers = ['Compute Templates']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and printsthe Images list.
  def query_image_list
    get_resource_list('image', 'v2/images', 'images')
    puts 'The list of Images in this PowerVC cloud are:'
    headers = ['Images']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and prints the supported SCG for each image.
  def query_image_scg_list
    query_image_list
    get_url('compute')
    @resource_id_list.each do |img|
      ind = @resource_id_list.index(img)
      puts "The supported Storage Connectivity groups for the image #{@resource_name_list[ind]} are:"
      response = rest_get("#{@resource_url}/images/#{img}/storage-connectivity-groups", @token_id)
      response_array = JSON.parse(response)
      @response_hash = response_array['storage_connectivity_groups']
      @response_hash.each do |scg|
        puts scg['display_name']
      end
    end
  end

  # Queries and prints the Networks list.
  def query_network_list
    get_resource_list('network', 'v2.0/networks', 'networks')
    puts 'The list of Networks in this PowerVC cloud are:'
    headers = ['Networks']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and prints the Volumes list.
  def query_volume_list
    get_resource_list('volume', 'volumes', 'volumes')
    puts 'The list of Volumes in this PowerVC cloud are:'
    headers = ['Volumes']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and prints the Storage Templates list.
  def query_volume_type_list
    get_resource_list('volume', 'types', 'volume_types')
    puts 'The list of Volume Types (Storage Templates) in this PowerVC cloud are:'
    headers = ['Storage Templates']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and prints the Projects list.
  def query_project_list
    get_resource_list('identity', 'projects', 'projects')
    puts 'The list of Projects in this PowerVC cloud are:'
    headers = ['Projects']
    print_table(headers, @resource_print_list)
    footer
  end

  # Queries and prints the Host Groups list.
  def query_host_group_list
    get_resource_list('compute', 'os-aggregates', 'aggregates', name = 'name', id = 'hosts')
    puts 'The list of Host Groups in this PowerVC cloud are:'
    headers = ['Host Groups']
    print_table(headers, @resource_print_list)
    footer
    puts 'The list of hosts are:'
    headers = ['Host Names']
    print_table(headers, @resource_id_print_list)
    footer
  end

  # Queries and prints the Storage Providers list.
  def query_storage_providers
    get_storage_providers
    puts 'The list of Storage Providers in this PowerVC cloud are:'
    headers = ['Storage Providers']
    print_table(headers, @stg_providers_print_list)
    footer
  end

  # Queries and prints the Fabrics list.
  def query_fabrics_list
    get_fabrics_list
    puts 'The list of Fabrics in this PowerVC cloud are:'
    headers = ['Fabrics']
    print_table(headers, @fabrics_print_list)
    footer
  end

  # Queries and prints the Storage Connectivity Groups.
  def query_scg_list
    get_resource_list('compute', 'storage-connectivity-groups', 'storage_connectivity_groups', name = 'display_name', id = 'id')
    puts 'The list of SCGs in this PowerVC cloud are:'
    headers = ['Storage Connectivity Groups']
    print_table(headers, @resource_print_list)
    footer
  end

  # Reports and creates the VM arrays.
  def report_server_list
    header
    puts 'Creating the VMs report'
    server_report
    begin
      print_table(@server_print_headers, @server_print_array)
    rescue NoMethodError
      puts 'The number of VMs seems to be zero!'
    end
  end

  # Reports and creates the Flavors arrays.
  def report_flavor_list
    header
    puts 'Creating the Compute Templates report. This may take a while (depending on the number of flavors exist)'
    flavor_report
    begin
      print_table(@flavor_print_headers, @flavor_print_array)
    rescue NoMethodError
      puts 'The number of Networks seems to be zero!'
    end
  end

  # Reports and creates the Networks arrays.
  def report_network_list
    header
    puts 'Creating the Networks report'
    network_report
    begin
      print_table(@network_print_headers, @network_print_array)
    rescue NoMethodError
      puts 'The number of Networks seems to be zero!'
    end
  end

  # Reports and creates the Volumes arrays.
  def report_volume_list
    header
    puts 'Creating the Volumes report'
    volume_report
    begin
      print_table(@volume_csv_headers, @volume_csv_array)
    rescue NoMethodError
      puts 'The number of Volumes seems to be zero!'
    end
  end

  # Reports and creates the Storage Templates arrays.
  def report_volume_type_list
    header
    puts 'Creating the Volumes report'
    volume_type_report
    begin
      print_table(@volume_type_csv_headers, @volume_type_csv_array)
    rescue NoMethodError
      puts 'The number of Storage Templates seems to be zero!'
    end
  end

  # Reports and creates the Storage Providers list.
  def report_stg_provider_list
    header
    puts 'Creating the Storage Providers report'
    stg_provider_report
    begin
      print_table(@stg_provider_csv_headers, @stg_provider_csv_array)
    rescue NoMethodError
      puts 'The number of Storage Providers seems to be zero!'
    end
  end

  # Reports and creates the SCG list.
  def report_scg_list
    header
    puts 'Creating the Storage Connectivity Group report'
    scg_report
    begin
      print_table(@scg_csv_headers, @scg_csv_array)
    rescue NoMethodError
      puts 'The number of Storage Connectivity Groups seems to be zero!'
    end
  end
end
