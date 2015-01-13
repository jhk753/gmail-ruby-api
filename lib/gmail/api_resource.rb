module Gmail
  class APIResource < GmailObject
    def self.class_name
      self.name.split('::')[-1]
    end

    def self.base_method
      Gmail.connect
      Gmail.service.users.send("#{class_name.downcase}s")
    end

  end
end