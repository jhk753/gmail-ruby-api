# encoding: utf-8
module Gmail
  class Message < APIResource
    include Base::List
    include Base::Delete
    include Base::Get
    include Base::Modify
    include Base::Trash

    require "stringex"

    after_initialize :set_basics

    def thread
      Thread.get(threadId)
    end

    def create_draft
      Draft.create(message: msg_parameters)
    end

    def deliver!
      response = Gmail.request(self.class.base_method.to_h['gmail.users.messages.send'],{}, msg_parameters)
      @values = Message.get(response[:id]).values
      self
    end

    def deliver
      response = Gmail.request(self.class.base_method.to_h['gmail.users.messages.send'],{}, msg_parameters)
      Message.get(response[:id])
    end

    def insert
      response = Gmail.request(self.class.base_method.insert,{}, msg_parameters)
      Message.get(response[:id])
    end

    def insert!
      response = Gmail.request(self.class.base_method.insert,{}, msg_parameters)
      @values = Message.get(response[:id]).values
      self
    end

    def reply_all_with msg
      msg = set_headers_for_reply msg
      msg = quote_in msg
      msg
    end

    def reply_sender_with msg
      msg = set_headers_for_reply msg
      msg = quote_in msg
      msg.cc = nil
      msg
    end

    def forward_with msg
      # save headers that need to be override by users compared to a classic reply
      x_cc = msg.cc
      x_to = msg.to
      x_bcc = msg.bcc
      x_subject = msg.subject || subject #if user doesn't override keep classic behavior
      # set headers as for reply
      msg = set_headers_for_reply msg
      # quote message
      msg = quote_in msg
      # reset saved overridden headers
      msg.cc = x_cc
      msg.to = x_to
      msg.bcc = x_bcc
      msg.subject = x_subject
      msg
    end


    def thread_id
      threadId
    end


    def unread?
      (labelIds||[]).include?("UNREAD")
    end

    def sent?
      (labelIds||[]).include?("SENT")
    end

    def inbox?
      (labelIds||[]).include?("INBOX")
    end



    def raw # is not in private because the method is used in Draft
      if super #check if raw is set to allow fully custom message to be sent
        super
      else
        s = self
        msg = Mail.new
        msg.subject = subject
        if body
          msg.body = body
        end
        msg.from = from
        msg.to   = to
        msg.cc = cc
        msg.header['X-Bcc'] = bcc unless bcc.nil?#because Mail gem doesn't allow bcc headers...
        msg.in_reply_to = in_reply_to  unless in_reply_to.nil?
        msg.references = references unless references.nil?
        if text || html
          bodypart = Mail::Part.new
          if text
            bodypart.text_part = Mail::Part.new do |p|
              content_type 'text/plain; charset=UTF-8'
              p.body s.text
            end
          end
          if html
            bodypart.html_part = Mail::Part.new do |p|
              content_type 'text/html; charset=UTF-8'
              p.body s.html
            end
          end
          msg.add_part bodypart
        end
        if attachments.present?
          if attachments.is_a?(Hash)
            attachments.each do |name, attachment|
              msg.add_file filename: name, content: attachment
            end
          elsif attachments.is_a?(Array)
            attachments.each do |attachment|
              msg.add_file(attachment)
            end
          end
        end
        Base64.urlsafe_encode64 msg.to_s.sub("X-Bcc", "Bcc") #because Mail gem doesn't allow bcc headers...
      end
    end

    private

    def msg_parameters
      msg = {raw: raw}
      if threadId
        msg[:threadId] = threadId
      end
      if labelIds
        msg[:labelIds] = labelIds
      end
      msg
    end

    def set_headers_for_reply msg
      #to_ar = []
      #split_regexp = Regexp.new("\s*,\s*")
      own_email = delivered_to || Gmail.mailbox_email


      to_ar = (Mail::AddressList.new("#{to}".to_ascii).addresses + Mail::AddressList.new("#{cc}".to_ascii).addresses).map(&:to_s)
      #to_ar = (to || "").split(split_regexp) + (cc || "").split(split_regexp)
      result = to_ar.grep(Regexp.new(own_email, "i"))
      to_ar = to_ar - result

      msg.subject = subject
      if from.match(Regexp.new(own_email, "i"))
        msg.to = to_ar.first
        to_ar = to_ar.drop(1)
      else
        msg.to = from
      end
      msg.cc = to_ar.join(", ")
      msg.bcc = nil
      msg.threadId = thread_id
      msg.references = ((references || "").split(Regexp.new "\s+") <<  message_id).join(" ")
      msg.in_reply_to = ((in_reply_to || "").split(Regexp.new "\s+") << message_id).join(" ")
      msg
    end

    def quote_in reply_msg
      text_to_append = "\r\n\r\n#{date} #{from}:\r\n\r\n>" + (body || text).gsub("\n", "\n>")  unless body.nil? && text.nil?
      html_to_append = "\r\n<br><br><div class=\"gmail_quote\"> #{date} #{CGI.escapeHTML(from)}:<br><blockquote class=\"gmail_quote\" style=\"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex\">" + html + "</blockquote></div><br>" unless html.nil?
      reply_msg.html = "<div>" + reply_msg.html + "</div>" + html_to_append unless reply_msg.html.nil?
      reply_msg.text = reply_msg.text + text_to_append unless reply_msg.text.nil?
      reply_msg.body = reply_msg.body + text_to_append unless reply_msg.body.nil?
      reply_msg
    end

    def urlsafe_decode64 code
      Base64.urlsafe_decode64(code).force_encoding('UTF-8').encode
    end


    def set_basics
      if @values.payload
        ["From", "To", "Cc", "Subject", "Bcc", "Date", "Message-ID", "References", "In-Reply-To", "Delivered-To"].each do |n|
          if payload_n = @values.payload.headers.select{|h| h.name.downcase == n.downcase}.first
            @values.send(n.downcase.tr("-", "_") + "=", payload_n.value)
          end
        end

        if payload.parts
          content_payload = @values.payload.find_all_object_containing("mimeType", "multipart/alternative").first
          content_payload ||= @values.payload
          text_part=content_payload.find_all_object_containing("mimeType", "text/plain").first
          if text_part
            @values.text = urlsafe_decode64(text_part.body.data)
          end
          html_part=content_payload.find_all_object_containing("mimeType", "text/html").first
          if html_part
            @values.html = urlsafe_decode64(html_part.body.data)
          end
        end
        if payload.body.data
          @values.body = urlsafe_decode64(@values.payload.body.data)
        end
      end
    end

    class Hashie::Mash
      def find_all_object_containing(key, value )
        result=[]
        if self.send(key) == value
          result << self
        end
        self.values.each do |vs|
          vs = [vs] unless vs.is_a? Array
          vs.each do |v|
            result += v.find_all_object_containing(key,value) if v.is_a? Hashie::Mash
          end
        end
        result
      end
    end

  end
end