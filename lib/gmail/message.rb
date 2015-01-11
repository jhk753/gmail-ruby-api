module Gmail
  class Message < APIResource
    include Gmail::Base::List
    include Gmail::Base::Create
    include Gmail::Base::Delete
    include Gmail::Base::Get

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
    end

    def thread_id
      threadId
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
      msg.bcc = bcc
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

      Base64.urlsafe_encode64 msg.to_s
    end

    def set_basics
      if @values.payload
        ["From", "To", "Cc", "Subject", "Bcc"].each do |n|
          if @values.payload.headers.select{|h| h.name == n}.first
            @values.send(n.downcase + "=", @values.payload.headers.select{|h| h.name == n}.first.value)
          end
        end

        if payload.parts
          @values.text = Base64.urlsafe_decode64 @values.payload.parts.select{|h| h.mimeType=="text/plain"}.first.body.data
          @values.html = Base64.urlsafe_decode64 @values.payload.parts.select{|h| h.mimeType=="text/html"}.first.body.data
        end
        if payload.body.data
          @values.body = Base64.urlsafe_decode64 @values.payload.body.data
        end
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


  end
end