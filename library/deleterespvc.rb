# Deleterespowervc module is used by the delete action to delete LPARs
module Deleterespowervc

  # Deletes mentioned VMs.
  def delete_server(lpar_name)
    @del_lpar_name = lpar_name.split(',')
    get_resource_list('compute', 'servers', 'servers')
    @del_lpar_name.each do |lpar|
      del_server_index = @resource_name_list.find_index(lpar)
      @del_server_id = @resource_id_list[del_server_index]
      get_url('compute')
      @server = rest_delete("#{@resource_url}/servers/#{@del_server_id}", @token_id)
      puts "Deleted LPAR #{lpar}"
    end
  end

  # Checks the status of the VMs scheduled to be deleted.
  def check_delete_status(lpar_name)
    puts 'Checking status of deleted LPARs'
    get_resource_list('compute', 'servers', 'servers')
    @del_lpar_name = lpar_name.split(',')
    @server_check_list = Array.new(@resource_name_list)
    @check_del_status = Array.new(@del_lpar_name)
    until @check_del_status.empty?
      @check_del_status.each do |lpar|
        if @server_check_list.include?(lpar)
          puts "#{lpar} is being deleted"
          puts 'Checking the next LPAR in the given list (if any)'
          get_resource_list('compute', 'servers', 'servers')
          @server_check_list = Array.new(@resource_name_list)
        else
          @check_del_status.delete(lpar)
        end
        puts 'waiting for 10 secs'
        sleep 10
      end
    end
    puts "LPAR(s) #{@del_lpar_name} has/have been deleted."
  end
end
