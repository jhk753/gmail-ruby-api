require 'gmail'
require 'test/unit'
require 'mocha/setup'
require 'stringio'
require 'shoulda'
require File.expand_path('../test_data', __FILE__)

# monkeypatch request methods
module Gmail
  @client = nil

  def self.connect

  end
end

class Test::Unit::TestCase
  include Gmail::TestData
  include Mocha

  setup do
    @mock = mock
    Gmail.client = @mock
    Gmail.new(client_id: "foo", client_secret: "foo", refresh_token: "foo", application_name: "test", application_version: "test")
  end

  teardown do
    Gmail.client = nil
    Gmail.client_id = nil
    Gmail.client_secret = nil
    Gmail.refresh_token = nil
  end
end