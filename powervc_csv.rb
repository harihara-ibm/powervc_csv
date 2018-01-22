#!/usr/bin/env ruby
# Main module that calls mixin modules based on the requested action
module PowerVCcsv
  require 'csv'
  require 'json'
  require 'rest-client'
  require 'terminal-table'
  require_relative 'library/authpvc'
  require_relative 'library/helperpvc'
  require_relative 'library/getrespvc'
  require_relative 'library/queryrespvc'
  require_relative 'library/reportrespvc'
  require_relative 'library/buildrespvc'
  require_relative 'library/deleterespvc'
  require_relative 'library/addstorage'

  # Class definition for the query operation
  class QueryResources
    include Authpowervc, Helperpowervc, Getrespowervc, Queryrespowervc, Reportrespowervc
  end

  # Class definition for the report operation
  class ReportResources
    include Authpowervc, Helperpowervc, Getrespowervc, Queryrespowervc, Reportrespowervc
  end

  # Class definition for the build operation
  class BuildServer
    include Authpowervc, Helperpowervc, Getrespowervc, Queryrespowervc, Buildrespowervc
  end

  # Class definition for the delete operation
  class DeleteServer
    include Authpowervc, Helperpowervc, Getrespowervc, Queryrespowervc, Deleterespowervc
  end

  # Class definition for the add-storage operation
  class AddStorage
    include Authpowervc, Helperpowervc, Getrespowervc, Queryrespowervc, Addstorage
  end

  # Class definition for the help operation
  class HelpMessage
    include Helperpowervc
  end

  # Main class that gets called by default
  class MainCaller
    include Helperpowervc
    
    # This is sort of the main menu, that calls various other mixin modules based on the requsted actions;
    # The mixins will then decide what resources to act upon! 
    def main_menu
      case @action
      when /query|q\b/i
        query = QueryResources.new
        query.gen_auth_token(@url, @user, @password, @project, @ssl_ca_file)
        query.query_main(@resource)
      when /report|r\b/i
        puts "Starting to create the report."
        report = ReportResources.new
        report.gen_auth_token(@url, @user, @password, @project, @ssl_ca_file)
        report.report_main(@resource)
      when /build|b\b/i
        puts 'Starting to build VMs'
        build = BuildServer.new
        build.gen_auth_token(@url, @user, @password, @project, @ssl_ca_file)
        build.resource_file_exists(@resource)
        build.build_server(@resource)
        build.check_server_status
        build.print_server_details
      when /delete|'d'\b/i
        puts 'Starting to delete VMs'
        delete = DeleteServer.new
        delete.gen_auth_token(@url, @user, @password, @project, @ssl_ca_file)
        delete.delete_server(@resource)
        delete.check_delete_status(@resource)
      when /help|h\b/i
        help = HelpMessage.new
        help.help_message(@resource)
      when /add-storage|as\b/i
        puts 'Starting to add Volumes'
        addstorage = AddStorage.new
        addstorage.gen_auth_token(@url, @user, @password, @project, @ssl_ca_file)
        addstorage.resource_file_exists(@resource)
        addstorage.check_server_health(@resource)
        addstorage.add_storage_volume(@resource)
      else
        help = HelpMessage.new
        help.help_message(@resource)
      end
    end
  end
end

# default caller to the MainCaller
maincaller = PowerVCcsv::MainCaller.new
maincaller.gather_inputs_from_rcfile
maincaller.initialize_vars
maincaller.main_menu
