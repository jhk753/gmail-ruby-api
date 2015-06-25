require 'mail'
require 'hashie'
require 'hooks'
require 'google/api_client'
require 'gmail/gmail_object'
require 'gmail/api_resource'
#base
require 'gmail/base/create'
require 'gmail/base/delete'
require 'gmail/base/get'
require 'gmail/base/list'
require 'gmail/base/update'
require 'gmail/base/modify'
require 'gmail/base/trash'

#object
require 'gmail/util'
require 'gmail/message'
require 'gmail/draft'
require 'gmail/thread'
require 'gmail/label'

module Gmail

  class << self
    attr_accessor :auth_method, :client_id, :client_secret, 
      :refresh_token, :auth_scopes, :email_account, :application_name, :application_version
    attr_reader :service, :client, :mailbox_email
    def new hash
      [:auth_method, :client_id, :client_secret, :refresh_token, :auth_scopes, :email_account, :application_name, :application_version].each do |accessor|
        Gmail.send("#{accessor}=", hash[accessor.to_s])
      end
    end
  end

  Google::APIClient.logger.level = 3
  @service = Google::APIClient.new.discovered_api('gmail', 'v1')
  Google::APIClient.logger.level = 2

  begin
    Gmail.new  YAML.load_file("account.yml")  # for development purpose
  rescue

  end

  def self.request(method, params={}, body={}, auth_method=@auth_method)
    
    puts auth_method
    params[:userId] ||= "me"
    if @client.nil?
      case auth_method
        when "web_application" 
          self.connect
        when "service_account"
          self.service_account_connect
        end
    end
    if body.empty?
      response = @client.execute(
          :api_method => method,
          :parameters => params,

          :headers => {'Content-Type' => 'application/json'})
    else

     response =  @client.execute(
          :api_method => method,
          :parameters => params,
          :body_object => body,
          :headers => {'Content-Type' => 'application/json'})
    end
    parse(response)

  end

  def self.mailbox_email
    @mailbox_email ||= self.request(@service.users.to_h['gmail.users.getProfile'])[:emailAddress]
  end



  def self.connect(client_id=@client_id, client_secret=@client_secret, refresh_token=@refresh_token)
    unless client_id
      raise 'No client_id specified'
    end

    unless client_secret
      raise 'No client_secret specified'
    end

    unless refresh_token
      raise 'No refresh_token specified'
    end

    @client = Google::APIClient.new(
        application_name: @application_name,
        application_version: @application_version
    )
    @client.authorization.client_id = client_id
    @client.authorization.client_secret = client_secret
    @client.authorization.refresh_token = refresh_token
    @client.authorization.grant_type = 'refresh_token'
    @client.authorization.fetch_access_token!
    @client.auto_refresh_token = true

    #@service = @client.discovered_api('gmail', 'v1')

  end

  def self.service_account_connect(
    client_id=@client_id, client_secret=@client_secret,
    email_account=@email_account, auth_scopes=@auth_scopes, 
    application_name=@application_name, application_version=@application_version
    )
    put "authenticating service account"
    

    @client = Google::APIClient.new(application_name: application_name, application_version: application_version)
      
      
    
    key = Google::APIClient::KeyUtils.load_from_pem(
        client_secret,
        'notasecret')
    asserter = Google::APIClient::JWTAsserter.new(
        client_id,
        auth_scopes, 
        key
    )
    @client.authorization = asserter.authorize(email_account)
    
  end

  def self.parse(response)
    begin

      if response.body.empty?
        return response.body
      else
        response = JSON.parse(response.body)
      end

    rescue JSON::ParserError
      raise "error code: #{response.error},body: #{response.body})"
    end

    r = Gmail::Util.symbolize_names(response)
    if r[:error]
      raise "#{r[:error]}"
    end
    r
  end


end # Gmail
