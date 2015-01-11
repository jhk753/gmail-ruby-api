module Gmail
  module Base
    module Create
      module ClassMethods
        def create(body, opts={})
          response = Gmail.request(base_method.send("create"), {}, body)
          Util.convert_to_gmail_object(response, class_name.downcase)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end