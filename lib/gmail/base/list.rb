module Gmail
  module Base
    module List
      module ClassMethods
        def all(filters={}, opts={})
          response = Gmail.request(base_method.send("list"), filters)
          Util.convert_to_gmail_object(response["#{class_name.downcase}s".to_sym], class_name.downcase)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end