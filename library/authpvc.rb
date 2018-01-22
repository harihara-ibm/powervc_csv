# Authpowervc module contains authentication function to powervc node
module Authpowervc

  # Get the auth token from PowerVC node, stores the token as @token_id to be used for API calls.
  def gen_auth_token(url,user,password, project, ssl_ca_file)
    @url = url; @user = user; @password = password; @project = project; @ssl_ca_file = ssl_ca_file
    @token_req_template = JSON.dump(
    {
      "auth": {
        "identity": {
          "methods": [
            "password"
          ],
          "password": {
            "user": {
              "domain": {
                "name": "Default"
              },
              "name": "#{@user}",
                "password": "#{@password}"
              }
            }
          },
          "scope": {
            "project": {
              "domain": {
                "name": "Default"
              },
              "name": "#{@project}"
            }
          }
        }
    })
    puts "Authorizing with PowerVC"
    begin
      @gen_tok = RestClient::Request.execute(method: :post, url: "#{@url}", payload: "#{@token_req_template}", headers: {'accept': 'application/json', 'content-type': 'application/json' }, :ssl_ca_file => "#{@ssl_ca_file}")
    rescue RestClient::SSLCertificateNotVerified
      puts "WARNING:
            Tried to do SSL certificate authentication but it failed.
            Proceeding without SSL authentication now, it is strongly recommended to use SSL certificates in Production environments."
      begin
        @gen_tok = RestClient::Request.execute(method: :post, url: "#{@url}", payload: "#{@token_req_template}", headers: {'accept': 'application/json', 'content-type': 'application/json' }, verify_ssl: false )
      rescue RestClient::Unauthorized
        puts "The PowerVC credentials provided in the powervcrc are not valid."
        puts "Please correct the errors in powervcrc file and run the tool again"
        exit
      rescue RestClient::Exceptions::OpenTimeout
        puts "Looks like there is either a network connection failure or the provided IP Address / Hostname for the PowerVC node in the powervcrc file is not valid."
        puts "Please correct the network situation or errors in the powervcrc file and run the tool again"
        exit
      end
    rescue RestClient::Unauthorized
      puts "TThe PowerVC credentials provided in the powervcrc are not valid."
      puts "Please correct the errors in powervcrc file and run the tool again"
      exit
    rescue RestClient::Exceptions::OpenTimeout
      puts "Looks like there is either a network connection failure or the provided IP Address / Hostname for the PowerVC node in the powervcrc file is not valid."
      puts "Please correct the network situation or errors in the powervcrc file and run the tool again"
      exit
    end
    @endpoints_hash = JSON.load(@gen_tok)['token']
    @tenant_id = @endpoints_hash['project']['id']
    @token_id = @gen_tok.headers[:x_subject_token]
    puts "Done"
  end

  # A function to get resource url, returns url in @resource_url.
  def get_url(resource)
    @endpoints_hash['catalog'].each do |entry|
      if entry['type'] == "#{resource}"
        entry['endpoints'].each do |endpoint|
          if endpoint['interface'] == 'public'
            @resource_url = endpoint['url']
          end
        end
      end
    end
  end
end
