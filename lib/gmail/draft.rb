module Gmail
  class Draft < APIResource
    include Gmail::Base::List
    include Gmail::Base::Create
    include Gmail::Base::Delete
    include Gmail::Base::Get

    def message

      msg = to_hash["message"]

      @values.message = Util.convert_to_gmail_object(msg, key="message")

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
      Gmail.request(self.class.base_method.send("update"),{id: id}, body)
      self
    end

    def deliver
      response = Gmail.request(self.class.base_method.to_h['gmail.users.drafts.send'],{},{id: id})
      Gmail::Message.get(response[:id])
    end



  end
end