module Gmail
  class Draft < APIResource
    include Base::List
    include Base::Create
    include Base::Delete
    include Base::Get
    include Base::Update

    def message
      if @values.message.is_a?(Message)
        @values.message
      else
        @values.message = Util.convert_to_gmail_object(to_hash[:message], key="message")
        if @values.message.payload.nil?
          self.detailed!
          message
        end
        @values.message
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
      Message.get(response[:id])
    end



  end
end