# -*- coding: utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

module Gmail
  class ThreadTest < Test::Unit::TestCase

    should "Threads should be listable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.threads.list, parameters: {userId: "me"}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread_list))
      list = Gmail::Thread.all
      assert_equal Array, list.class
      assert_equal Gmail::Thread, list[0].class
    end

    should "Thread should be retrievable by id" do

        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.get, parameters: {userId: "me", id: test_thread[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread))
        t = Gmail::Thread.get(test_thread[:id])
        assert_equal Gmail::Thread, t.class
        assert_equal test_thread[:id], t.id
    end


    context "Access list of Messages from thread" do
      should "Access list of Messages" do
        thread = Gmail::Thread.new test_thread
       # @mock.expects(:execute).with(api_method: Gmail.service.users.messages.list, parameters: {userId: "me", threadId: [test_thread[:id]]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message_list))
        list = thread.messages
        assert_equal Array, list.class
        assert_equal Gmail::Message, list[0].class
      end

      should "Access list of Messages after selecting from list" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.list, parameters: {userId: "me"}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread_list))
        thread_list = Gmail::Thread.all
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.get, parameters: {userId: "me", id: test_thread[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message_list))
        thread = thread_list.first
        list = thread.messages
        assert_equal Array, list.class
        assert_equal Gmail::Message, list[0].class
      end


      should 'Access list of unread Messages' do
        thread = Gmail::Thread.new test_thread
        #@mock.expects(:execute).with(api_method: Gmail.service.users.messages.list, parameters: {userId: "me", threadId: [test_thread[:id]], labelIds: ["UNREAD"]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message_list))
        list = thread.unread_messages
        assert_equal Array, list.class
        assert_equal Gmail::Message, list[0].class
      end

      should 'Access list of sent Messages' do
        thread = Gmail::Thread.new test_thread
       # @mock.expects(:execute).with(api_method: Gmail.service.users.messages.list, parameters: {userId: "me", threadId: [test_thread[:id]], labelIds: ["SENT"]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message_list))
        list = thread.unread_messages
        assert_equal Array, list.class
        assert_equal Gmail::Message, list[0].class
      end
    end


    should "Thread should be deletable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.threads.delete, parameters: {userId: "me", id: test_thread[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(""))
      t = Gmail::Thread.new(test_thread)
      r = t.delete
      assert r
    end

    should "Thread should be thrashable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.threads.trash, parameters: {userId: "me", id: test_thread[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread))
      t = Gmail::Thread.new(test_thread)
      r = t.trash
      assert_equal Gmail::Thread, r.class
    end

    should "Thread should be unthrashable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.threads.untrash, parameters: {userId: "me", id: test_thread[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread))
      t = Gmail::Thread.new(test_thread)
      r = t.untrash
      assert_equal Gmail::Thread, r.class
    end

    context "Modifying Labels" do
      should "Thread should be starrable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: ["STARRED"], removeLabelIds: []} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.star
        assert_equal Gmail::Thread, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.star!

        assert_equal t.object_id, r.object_id

      end

      should "Thread should be unstarrable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: [], removeLabelIds: ["STARRED"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.unstar
        assert_equal Gmail::Thread, r.class

        assert_not_equal t.object_id, r.object_id

        r = t.unstar!

        assert_equal t.object_id, r.object_id
      end

      should "Thread should be archivable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: [], removeLabelIds: ["INBOX"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.archive
        assert_equal Gmail::Thread, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.archive!

        assert_equal t.object_id, r.object_id
      end

      should "Thread should be unarchivable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: ["INBOX"], removeLabelIds: []} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.unarchive
        assert_equal Gmail::Thread, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.unarchive!

        assert_equal t.object_id, r.object_id
      end

      should "Thread should be markable as read" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: [], removeLabelIds: ["UNREAD"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.mark_as_read
        assert_equal Gmail::Thread, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.mark_as_read!

        assert_equal t.object_id, r.object_id
      end

      should "Thread should be markable as unread" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: ["UNREAD"], removeLabelIds: []} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.mark_as_unread
        assert_equal Gmail::Thread, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.mark_as_unread!

        assert_equal t.object_id, r.object_id
      end


      should "Thread label should be modifiable as wish" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.threads.modify, parameters: {userId: "me", id: test_thread[:id]}, body_object: {addLabelIds: ["UNREAD", "SOME COOL LABEL"], removeLabelIds: ["INBOX", "SOME NOT COOL LABEL"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_thread))
        t = Gmail::Thread.new(test_thread)
        r = t.modify ["UNREAD", "SOME COOL LABEL"], ["INBOX", "SOME NOT COOL LABEL"]
        assert_equal Gmail::Thread, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.modify! ["UNREAD", "SOME COOL LABEL"], ["INBOX", "SOME NOT COOL LABEL"]

        assert_equal t.object_id, r.object_id
      end

    end


    should "Thread should be searcheable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.threads.list, parameters: {userId: "me", q: "from:(me) to:(you) subject:(subject) in:inbox before:2014/12/1 after:2014/11/1 test -{real}", labelIds:["UNREAD"]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread_list))
      list = Gmail::Thread.search(from:"me", to: "you", subject: "subject", in: "inbox", before: "2014/12/1", after: "2014/11/1", has_words: "test", has_not_words: "real", labelIds: ["UNREAD"])
      assert_equal Array, list.class
      assert_equal Gmail::Thread, list[0].class
    end




  end
end