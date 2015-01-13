module Gmail
  class Thread < APIResource
    include Gmail::Base::List
    include Gmail::Base::Create
    include Gmail::Base::Delete
    include Gmail::Base::Get
    include Gmail::Base::Modify
    include Gmail::Base::Trash

    def messages

      msgs = to_hash["messages"] || detailed.messages

      Util.convert_to_gmail_object(msgs, key="message")

    end

    def unread_messages

      messages.select{|m| m.unread?}

    end


    def sent_messages

      messages.select{|m| m.sent?}

    end

  end
end