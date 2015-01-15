# -*- coding: utf-8 -*-
# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

module Gmail
  class MessageTest < Test::Unit::TestCase

    should "messages should be listable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.list, parameters: {userId: "me"}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message_list))
      list = Gmail::Message.all
      assert_equal Array, list.class
      assert_equal Gmail::Message, list[0].class
    end

    should "message should be retrievable by id" do

      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.get, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message))
      t = Gmail::Message.get(test_message[:id])
      assert_equal Gmail::Message, t.class
      assert_equal test_message[:id], t.id
    end

    should "message construct should set some basics values" do

      m = Gmail::Message.new(test_message)
      ["From", "To", "Cc", "Subject", "Bcc", "Date", "Message-ID", "References", "In-Reply-To", "Delivered-To"].each do |method|
        assert_equal test_message[:payload][:headers].select{|h| h[:name].downcase == method.downcase}.first[:value], m.send(method.downcase.tr("-", "_"))
      end
      assert_not_nil m.text || m.body || m.html

    end

    should "message (with strange format) construct should set at least body, text or html" do

      m = Gmail::Message.new(test_strange_message)
      assert_not_nil m.text || m.body || m.html

    end




    should "Access thread from message" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.threads.get, parameters: {userId: "me", id: test_message[:threadId]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_thread))
      m = Gmail::Message.new(test_message)
      t = m.thread
      assert_equal test_message[:threadId], m.thread_id
      assert_equal Gmail::Thread, t.class
    end

    should "message should be deletable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.delete, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(""))
      t = Gmail::Message.new(test_message)
      r = t.delete
      assert r
    end

    should "message should be thrashable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.trash, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message))
      t = Gmail::Message.new(test_message)
      r = t.trash
      assert_equal Gmail::Message, r.class
    end

    should "message should be unthrashable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.untrash, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message))
      t = Gmail::Message.new(test_message)
      r = t.untrash
      assert_equal Gmail::Message, r.class
    end

    context "Modifying Labels" do
      should "message should be starrable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: ["STARRED"], removeLabelIds: []} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.star
        assert_equal Gmail::Message, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.star!

        assert_equal t.object_id, r.object_id

      end

      should "message should be unstarrable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: [], removeLabelIds: ["STARRED"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.unstar
        assert_equal Gmail::Message, r.class

        assert_not_equal t.object_id, r.object_id

        r = t.unstar!

        assert_equal t.object_id, r.object_id
      end

      should "message should be archivable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: [], removeLabelIds: ["INBOX"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.archive
        assert_equal Gmail::Message, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.archive!

        assert_equal t.object_id, r.object_id
      end

      should "message should be unarchivable" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: ["INBOX"], removeLabelIds: []} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.unarchive
        assert_equal Gmail::Message, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.unarchive!

        assert_equal t.object_id, r.object_id
      end

      should "message should be markable as read" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: [], removeLabelIds: ["UNREAD"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.mark_as_read
        assert_equal Gmail::Message, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.mark_as_read!

        assert_equal t.object_id, r.object_id
      end

      should "message should be markable as unread" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: ["UNREAD"], removeLabelIds: []} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.mark_as_unread
        assert_equal Gmail::Message, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.mark_as_unread!

        assert_equal t.object_id, r.object_id
      end


      should "message label should be modifiable as wish" do
        @mock.expects(:execute).with(api_method: Gmail.service.users.messages.modify, parameters: {userId: "me", id: test_message[:id]}, body_object: {addLabelIds: ["UNREAD", "SOME COOL LABEL"], removeLabelIds: ["INBOX", "SOME NOT COOL LABEL"]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))
        t = Gmail::Message.new(test_message)
        r = t.modify ["UNREAD", "SOME COOL LABEL"], ["INBOX", "SOME NOT COOL LABEL"]
        assert_equal Gmail::Message, r.class
        assert_not_equal t.object_id, r.object_id

        r = t.modify! ["UNREAD", "SOME COOL LABEL"], ["INBOX", "SOME NOT COOL LABEL"]

        assert_equal t.object_id, r.object_id
      end

    end


    should "Helpers should work" do
      m = Gmail::Message.new test_message
      assert_false m.sent?
      assert_false m.inbox?
      assert_false m.unread?
      m = Gmail::Message.new test_inbox_message
      assert_false m.sent?
      assert m.inbox?
      assert_false m.unread?
      m = Gmail::Message.new test_sent_message
      assert m.sent?
      assert_false m.inbox?
      assert_false m.unread?
      m = Gmail::Message.new test_unread_message
      assert_false m.sent?
      assert_false m.inbox?
      assert m.unread?
    end


    should "Message should be searcheable" do
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.list, parameters: {userId: "me", q: "from:(me) to:(you) subject:(subject) in:inbox before:2014/12/1 after:2014/11/1 test -{real}", labelIds:["UNREAD"]}, headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_message_list))
      list = Gmail::Message.search(from:"me", to: "you", subject: "subject", in: "inbox", before: "2014/12/1", after: "2014/11/1", has_words: "test", has_not_words: "real", labelIds: ["UNREAD"])
      assert_equal Array, list.class
      assert_equal Gmail::Message, list[0].class
    end

    should "Message should construct RAW string correctly" do
      m = Gmail::Message.new test_message
      raw = Mail.new(Base64.urlsafe_decode64(m.raw))
      assert raw.from
      assert raw.to
      assert raw.cc
      assert_equal m.bcc, raw.header['Bcc'].value
      assert_equal m.subject, raw.subject
      assert_equal m.in_reply_to, "<#{raw.in_reply_to}>"
      assert_equal m.references.tr("<", "").tr(">", "").split(" "), raw.references
      assert raw.text_part.body.raw_source
      assert raw.html_part.body.raw_source
    end

    should "Draft can be created from Message" do
      m = Gmail::Message.new test_message
      # raw generation change between two calls because date won't be the same...
      m.raw = m.raw
      ###
      @mock.expects(:execute).with(api_method: Gmail.service.users.drafts.create, parameters: {userId: "me"}, body_object:{message: {raw: m.raw, threadId: test_message[:threadId], labelIds: test_message[:labelIds]}} , headers: {'Content-Type' => 'application/json'}).once.returns(test_response(test_draft))
      d = m.create_draft
      assert_equal Gmail::Draft, d.class

    end

    should "Message should be sendable and return a Message" do

      m = Gmail::Message.new test_message
      m.raw = m.raw
      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.to_h['gmail.users.messages.send'], parameters: {userId: "me"}, body_object:{raw: m.raw, labelIds: test_message[:labelIds], threadId: test_message[:threadId]} , headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))

      @mock.expects(:execute).with(api_method: Gmail.service.users.messages.get, parameters: {userId: "me", id: test_message[:id]}, headers: {'Content-Type' => 'application/json'}).twice.returns(test_response(test_message))


      new_m = m.deliver
      assert_equal Gmail::Message, new_m.class
      assert_not_equal new_m.object_id, m.object_id

      new_m = m.deliver!
      assert_equal Gmail::Message, new_m.class
      assert_equal new_m.object_id, m.object_id
    end


    should "Reply to sender contruct should be easy" do
      m = Gmail::Message.new test_to_reply_message
      reply_message = Gmail::Message.new test_reply_message
      @mock.expects(:execute).never
      expected_msg = Gmail::Message.new test_replied_message
      new_m = m.reply_sender_with reply_message

      assert_equal expected_msg.to, new_m.to
      assert_nil new_m.cc
      assert_nil new_m.bcc
      assert_equal expected_msg.subject, new_m.subject
      assert_equal expected_msg.references, new_m.references
      assert_equal expected_msg.in_reply_to, new_m.in_reply_to
      assert_equal expected_msg.thread_id, new_m.thread_id
      assert_equal expected_msg.body, new_m.body
      assert_nil new_m.html
      assert_nil new_m.text

      new_m = m.reply_sender_with(Gmail::Message.new test_reply_message_with_html)
      expected_msg = Gmail::Message.new(test_replied_message_with_html)

      assert_equal expected_msg.text, new_m.text
      assert_equal expected_msg.html, new_m.html
      assert_nil new_m.body

    end

    should "Reply to all construct should be easy" do
      m = Gmail::Message.new test_to_reply_message
      reply_message = Gmail::Message.new test_reply_message
      @mock.expects(:execute).never
      new_m = m.reply_all_with reply_message
      expected_msg = Gmail::Message.new test_replied_message

      assert_equal expected_msg.to, new_m.to
      assert_equal expected_msg.cc, new_m.cc
      assert_nil new_m.bcc
      assert_equal expected_msg.subject, new_m.subject
      assert_equal expected_msg.references, new_m.references
      assert_equal expected_msg.in_reply_to, new_m.in_reply_to
      assert_equal expected_msg.thread_id, new_m.thread_id
      assert_equal expected_msg.body, new_m.body
      assert_nil new_m.html
      assert_nil new_m.text

      new_m = m.reply_all_with(Gmail::Message.new test_reply_message_with_html)
      expected_msg = Gmail::Message.new(test_replied_message_with_html)

      assert_equal expected_msg.text, new_m.text
      assert_equal expected_msg.html, new_m.html
      assert_nil new_m.body


    end

    should "forward construct should be easy" do
      m = Gmail::Message.new test_to_reply_message
      forward_message = Gmail::Message.new(test_forward_message)
      @mock.expects(:execute).never
      new_m = m.forward_with forward_message
      expected_msg = Gmail::Message.new test_forwarded_message
      # to be completed to be fully tested

      assert_equal expected_msg.to, new_m.to
      assert_equal expected_msg.cc, new_m.cc
      assert_nil new_m.bcc
      assert_equal expected_msg.subject, new_m.subject
      assert_equal expected_msg.references, new_m.references
      assert_equal expected_msg.in_reply_to, new_m.in_reply_to
      assert_equal expected_msg.thread_id, new_m.thread_id
      assert_equal expected_msg.body, new_m.body
      assert_nil new_m.html
      assert_nil new_m.text

      forward_message = Gmail::Message.new({to: "test@test.com", bbc: "coucou", cc: "test@couocu.com, second@second.com", subject: "cool subject", html: "<b>test</b>", text: "test"})
      new_m = m.forward_with forward_message
      expected_msg = Gmail::Message.new test_forwarded_message_with_html

      assert_equal expected_msg.text, new_m.text
      assert_equal expected_msg.html, new_m.html
      assert_nil new_m.body
    end

  end
end