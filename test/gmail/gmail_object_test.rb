require File.expand_path('../../test_helper', __FILE__)

module Gmail
  class GmailObjectTest < Test::Unit::TestCase
    should "implement #respond_to correctly" do
      obj = Gmail::GmailObject.new({ :id => 1, :foo => 'bar' })
      assert_not_nil obj.id
      assert_not_nil obj.foo
      assert_nil obj.other
    end

    should "detail and refresh a Gmail object correctly" do
      obj = Gmail::GmailObject.new test_message
      exception = assert_raise do obj.refresh end
      assert_equal "Can't refresh a generic GmailObject. It needs to be a Thread, Message, Draft or Label", exception.message
      exception  = assert_raise do obj.detailed end
      assert_equal "Can't detail a generic GmailObject. It needs to be a Thread, Message, Draft or Label", exception.message

      not_generic_object = Gmail::Message.new test_message
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.get, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))

      new_o = not_generic_object.detailed
      assert_not_equal new_o.object_id, not_generic_object.object_id

      new_o = not_generic_object.refresh
      assert_equal new_o.object_id, not_generic_object.object_id

    end

    should "recursively call to_hash on GmailObject" do
      nested = Gmail::GmailObject.new({ :id => 7, :foo => 'bar' })
      obj = Gmail::GmailObject.new({ :id => 1})
      obj.nested = nested
      expected_hash = { :id => 1, :nested => {:id => 7, :foo => 'bar'} }
      assert_equal expected_hash, obj.to_hash
    end

  end
end