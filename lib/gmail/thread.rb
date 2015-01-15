module Gmail
  class Thread < APIResource
    include Base::List
    include Base::Delete
    include Base::Get
    include Base::Modify
    include Base::Trash

    def messages

      if @values.messages.is_a? Array
        if @values.messages.first.is_a? Message
          @values.messages
        else
          @values.messages = Util.convert_to_gmail_object(to_hash[:messages], key="message")
        end
      else
        self.detailed!
        messages
      end

    end

    def unread_messages

      messages.select{|m| m.unread?}

    end


    def sent_messages

      messages.select{|m| m.sent?}

    end

  end
end