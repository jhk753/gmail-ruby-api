require 'mail'
require 'date'
require 'time'
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

#object
require 'gmail/util'
require 'gmail/message'
require 'gmail/draft'
require 'gmail/thread'
require 'gmail/label'



module Gmail

  @client_id ||= YAML.load_file("env.yml")["GOOGLE_CLIENT_ID"]
  @client_secret ||= YAML.load_file("env.yml")["GOOGLE_CLIENT_SECRET"]
  @refresh_token ||= YAML.load_file("env.yml")["GOOGLE_REFRESH_TOKEN"]

  class << self
    attr_accessor :client_id, :client_secret, :refresh_token, :client, :service
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

  def self.connect(client_id=nil, client_secret=nil, refresh_token=nil)
    unless client_id ||= @client_id
      raise 'No client_id specified'
    end

    unless client_secret ||= @client_secret
      raise 'No client_secret specified'
    end

    unless refresh_token ||= @refresh_token
      raise 'No refresh_token specified'
    end

    @client = Google::APIClient.new(
        application_name: 'Juliedesk',
        application_version: '1.0.0'
    )
    @client.authorization.client_id = client_id
    @client.authorization.client_secret = client_secret
    @client.authorization.refresh_token = refresh_token
    @client.authorization.grant_type = 'refresh_token'
    @client.authorization.fetch_access_token!

    @service = @client.discovered_api('gmail', 'v1')

  end

  def self.parse(response)
    begin
      # Would use :symbolize_names => true, but apparently there is
      # some library out there that makes symbolize_names not work.
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

  if @client_id && @client_secret && @refresh_token
    Gmail.connect
  end

end # Gmail
