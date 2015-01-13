module Gmail
  class Draft < APIResource
    include Gmail::Base::List
    include Gmail::Base::Create
    include Gmail::Base::Delete
    include Gmail::Base::Get
    include Gmail::Base::Update

    def message
      if @values.message.is_a?(Gmail::Message)
        @values.message
      else
        @values.message = Util.convert_to_gmail_object(to_hash["message"], key="message").detailed
      end
    end

    def save(opts={})
      msg = {raw: message.raw}
      if message.threadId
        msg[:threadId] = message.threadId
      end
      if message.labelIds
        msg[:labelIds] = message.labelIds
      end
      body = {message: msg}
      update(body)
    end

    def save!(opts={})
      msg = {raw: message.raw}
      if message.threadId
        msg[:threadId] = message.threadId
      end
      if message.labelIds
        msg[:labelIds] = message.labelIds
      end
      body = {message: msg}
      update!(body)
    end

    def deliver
      response = Gmail.request(self.class.base_method.to_h['gmail.users.drafts.send'],{},{id: id})
      Gmail::Message.get(response[:id])
    end



  end
end