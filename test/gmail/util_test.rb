# -*- coding: utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

module Gmail
  class UtilTest < Test::Unit::TestCase

    should "Symbolize Name should work properly" do
      assert_equal(({:test1=> "test"}), Gmail::Util.symbolize_names({"test1"=>'test'}))
      m =Gmail::Message.new test_message
      assert_equal m, Gmail::Util.symbolize_names(m)
      assert_equal(({test: {nested:[{coucou: "1", coucou2: "2"}]}}), Gmail::Util.symbolize_names({"test"=>{"nested"=>[{"coucou"=>"1","coucou2"=>"2"}]}}))
      assert_equal [{coucou: "1", coucou2: "2"}], Gmail::Util.symbolize_names([{"coucou"=>"1", "coucou2"=>"2"}])
    end

    #testing of convert_to_gmail_object is not necessary as it is tested through all other test files

  end
end