module Gmail
  module Base
    module Update
      def update!(body)
        if id.nil?
          d = self.class.create(body)
        else
          response = Gmail.request(self.class.base_method.send("update"),{id: id}, body)
          d = Util.convert_to_gmail_object(response, self.class.class_name.downcase)
        end
        @values = d.values
        self
      end

      def update(body)
        if id.nil?
          d = self.class.create(body)
        else
          response = Gmail.request(self.class.base_method.send("update"),{id: id}, body)
          d = Util.convert_to_gmail_object(response, self.class.class_name.downcase)
        end
        d
      end
    end
  end
end