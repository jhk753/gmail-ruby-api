# -*- coding: utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

module Gmail
  class DraftTest < Test::Unit::TestCase

    should "Draft should be retrievable by id" do

      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.get, parameters: {userId: "me", id: test_draft[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_draft))
      d = Gmail::Draft.get(test_draft[:id])
      assert d.kind_of?Gmail::Draft
      assert_equal test_draft[:id], d.id
    end

    should "drafts should be listable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.list, parameters: {userId: "me"}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_draft_list))
      list = Gmail::Draft.all
      assert list.kind_of? Array
      assert list[0].kind_of? Gmail::Draft
    end

  context "Message Object in draft" do
    should "retrieved Draft should not generate call to get Message Object" do
      draft = Gmail::Draft.new(test_draft)
      @mock.expects(:execute).never
      assert draft.message.kind_of?Gmail::Message
    end

    should "Draft get from a draft list should generate call to get Message Object" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.list, parameters: {userId: "me"}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_draft_list))
      list = Gmail::Draft.all
      draft = list.first

      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.get, parameters: {userId: "me", id: test_draft[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_draft))

      assert draft.message.kind_of?Gmail::Message
      assert_not_nil draft.message.payload
    end
  end


    should "drafts should be deletable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.delete, parameters: {userId: "me", id: test_draft[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(""))
      d = Gmail::Draft.new(test_draft)
      r = d.delete
      assert r
    end

    should "drafts should be updateable" do
      draft_hash = test_draft
      draft_hash[:message].merge!({labelIds: ["COOL LABEL"]})
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.get, parameters: {id: test_draft[:id], userId: "me"} , headers: {'Content-Type' => 'application/json'}).once.returns(test_response(draft_hash))

      d = Gmail::Draft.new(id: test_draft[:id]).detailed
      # those two lines are required because raw generation change between two calls...
      raw = d.message.raw
      d.message.raw = raw
      ###
      assert_equal ["COOL LABEL"], d.message.labelIds

      draft_hash[:message].merge!({labelIds: ["INBOX"]})

      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.update, parameters: {id: test_draft[:id], userId: "me"}, body_object:{message: {raw: d.message.raw, threadId: test_draft[:message][:threadId], labelIds: ["INBOX"]}} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(draft_hash))


      d.message.labelIds = ["INBOX"]
      new_d = d.save
      assert_equal ["INBOX"], new_d.message.labelIds
      assert_not_equal d.object_id, new_d.object_id
      new_d = d.save!
      assert_equal d.object_id, new_d.object_id
    end

    should "create should return a new Draft" do
      draft_hash = test_draft
      draft_hash.delete(:id)
      d = Gmail::Draft.new draft_hash
      # those two lines are required because raw generation change between two calls...
      raw = d.message.raw
      d.message.raw = raw
      ###
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.create, parameters: {userId: "me"}, body_object:{message: {raw: d.message.raw, threadId: draft_hash[:message][:threadId], labelIds: draft_hash[:message][:labelIds]}} , headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_draft))
      created_d = d.save!
      assert_equal Gmail::Draft, created_d.class
      assert_equal test_draft[:id], d.id
    end


    should "Draft should be sendable and return a Message" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.to_h['gmail.users.drafts.send'], parameters: {userId: "me"}, body_object:{id: test_draft[:id]} , headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message))
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.get, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message))

      d = Gmail::Draft.new test_draft
      m = d.deliver

      assert m.kind_of?Gmail::Message

    end




  end
end