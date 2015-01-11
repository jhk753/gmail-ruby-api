module Gmail
  class Thread < APIResource
    include Gmail::Base::List
    include Gmail::Base::Create
    include Gmail::Base::Delete
    include Gmail::Base::Get

    def messages

      msgs = to_hash["messages"] || detailed.messages

      Util.convert_to_gmail_object(msgs, key="message")

    end

  end
end