module Gmail
  class Message < APIResource
    include Gmail::Base::List
    include Gmail::Base::Create
    include Gmail::Base::Delete
    include Gmail::Base::Get
    include Gmail::Base::Modify
    include Gmail::Base::Trash

    after_initialize :set_basics

    def thread
      Gmail::Thread.get(threadId)
    end

    def create_draft
      Gmail::Draft.create(message: msg_parameters)
    end

    def deliver
      response = Gmail.request(self.class.base_method.to_h['gmail.users.messages.send'],{}, msg_parameters)
      @values = Gmail::Message.get(response[:id]).values
      self
    end

    def reply_all_with msg
      msg = set_headers_for_reply msg
      #msg = set_body_for_reply msg
      msg.deliver
    end

    def reply_sender_with msg
      msg = set_headers_for_reply msg
     # msg = set_body_for_reply msg
      msg.cc = nil
      msg.deliver
    end

    def forward_with msg
      # save headers that need to be override by users compared to a classic reply
      x_cc = msg.cc
      x_to = msg.to
      x_bcc = msg.bcc
      x_subject = msg.subject || subject #if user doesn't override keep classic behavior
      # set headers as for reply
      msg = set_headers_for_reply msg
      # reset saved overridden headers
      msg.cc = x_cc
      msg.to = x_to
      msg.bcc = x_bcc
      msg.subject = x_subject
      #send message
      msg.deliver
    end


    def thread_id
      threadId
    end


    def unread?
      labelIds.include?("UNREAD")
    end

    def sent?
      labelIds.include?("SENT")
    end

    def inbox?
      labelIds.include?("INBOX")
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
      msg.subject = subject
      msg.to = from
      msg.cc = cc
      msg.bcc = nil
      msg.threadId = thread_id
      msg.references = (references || "") + " " + message_id
      msg.in_reply_to = (in_reply_to || "") + " " + message_id
      msg
    end

    def urlsafe_decode64 code
      Base64.urlsafe_decode64(code).force_encoding('UTF-8').encode


    end


    def set_basics
      if @values.payload
        ["From", "To", "Cc", "Subject", "Bcc", "Date", "Message-ID", "References", "In-Reply-To"].each do |n|
          if @values.payload.headers.select{|h| h.name == n}.first
            @values.send(n.downcase.tr("-", "_") + "=", @values.payload.headers.select{|h| h.name == n}.first.value)
          end
        end

        if payload.parts
          @values.text = urlsafe_decode64(@values.payload.parts.select{|h| h.mimeType=="text/plain"}.first.body.data)
          @values.html = urlsafe_decode64(@values.payload.parts.select{|h| h.mimeType=="text/html"}.first.body.data)
        end
        if payload.body.data
          @values.body = urlsafe_decode64(@values.payload.body.data)
        end
      end
    end


    def raw
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
      msg.header['In-Reply-To'] = in_reply_to
      msg.header['References'] = references
      if text
        msg.text_part = Mail::Part.new do |p|
          p.body s.text
        end
      end
      if html
        msg.html_part = Mail::Part.new do |p|
          content_type 'text/html; charset=UTF-8'
          p.body s.html
        end
      end

      Base64.urlsafe_encode64 msg.to_s.sub("X-Bcc", "Bcc") #because Mail gem doesn't allow bcc headers...
    end



  end
end