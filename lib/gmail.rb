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
    attr_accessor :client_id, :client_secret, :refresh_token, :client, :service, :application_name, :application_version
    def new hash
      [:client_id, :client_secret, :refresh_token, :application_name, :application_version].each do |accessor|
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

  def self.request(method, params={}, body={})
    params[:userId] ||= "me"
    if @client.nil?
      self.connect
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

    r = Util.symbolize_names(response)
    if r[:error]
      raise "#{r[:error]}"
    end
    r
  end


end # Gmail
