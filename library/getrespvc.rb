# Getrespowervc is used by all other modules to get existing resource information
module Getrespowervc

  # Function gets the Resource name and ID in separate arrays for the provided PowerVC resource.
  def get_resource_list(resource, url_type, rest_type, name = 'name', id = 'id')
    get_url(resource)
    @resource_name_list = []
    @resource_print_list = []
    @resource_id_list = []
    @resource_id_print_list = []
    @rest_response = rest_get("#{@resource_url}/#{url_type}", @token_id)
    @rest_array = JSON.parse(@rest_response)["#{rest_type}"]
    @resource_name_list = []
    @resource_id_list = []
    @rest_array.each do |res|
      @resource_name_list << res[name]
      @resource_print_list << [res[name]]
      @resource_id_list << res[id]
      @resource_id_print_list << [res[id]]
    end
  end

  # Special method for storage providers, as the response from PowerVC is different from other resources.
  def get_storage_providers
    get_url('volume')
    @stg_providers_list = []
    @stg_providers_print_list = []
    @stg_providers_id_list = []
    @volume_url = @resource_url
    @stg_providers = rest_get("#{@volume_url}/storage-providers/detail", @token_id)
    @stg_providers_array = JSON.parse(@stg_providers)['storage_providers']
    @stg_providers_array.each do |stg|
      @stg_providers_list << stg['service']['host_display_name']
      @stg_providers_print_list << [stg['service']['host_display_name']]
      @stg_providers_id_list << stg['id']
    end
  end

  # Special method for fabrics, as the response from PowerVC is different from other resources.
  def get_fabrics_list
    get_url('volume')
    @fabrics_list = []
    @fabrics_print_list = []
    @volume_url = @resource_url
    @fabrics = rest_get("#{@volume_url}/san-fabrics", @token_id)
    @fabrics_array = JSON.parse(@fabrics)['fabrics']
    @fabrics_list = []
    @fabrics_array.each do |fabric|
      @fabrics_list << fabric['fabric_name']
      @fabrics_print_list << [fabric['fabric_name']]
    end
  end
end
