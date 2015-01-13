module Gmail
  module Base
    module Delete
      def delete(opts={})
        response = Gmail.request(self.class.base_method.send("delete"),{id: id})
        if response == ""
          true
        else
          false
        end
      end

      module ClassMethods
        def delete(id, opts={})
         response = Gmail.request(base_method.send("delete"),{id: id})
         if response == ""
           true
         else
           false
         end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end


    end
  end
end