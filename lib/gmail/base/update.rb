module Gmail
  module Base
    module Update
      def update(body)
        if id.nil?
          d = Gmail::Draft.create(body)
        else
          response = Gmail.request(self.class.base_method.send("update"),{id: id}, body)
          d = Util.convert_to_gmail_object(response, self.class.class_name.downcase)
        end
        @values = d.values
        self
      end
    end
  end
end