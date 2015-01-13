module Gmail
  module Base
    module Modify
      def modify!(addLabelIds=[], removeLabelIds=[])
        response = Gmail.request(self.class.base_method.send("modify"),{id: id}, {addLabelIds: addLabelIds, removeLabelIds: removeLabelIds})
        d = Util.convert_to_gmail_object(response, self.class.class_name.downcase)
        @values = d.values
        self
      end

      def modify(addLabelIds=[], removeLabelIds=[])
        response = Gmail.request(self.class.base_method.send("modify"),{id: id}, {addLabelIds: addLabelIds, removeLabelIds: removeLabelIds})
        d = Util.convert_to_gmail_object(response, self.class.class_name.downcase)
      end

      def archive
        modify([], ["INBOX"])
      end

      def archive!
        modify!([], ["INBOX"])
      end

      def unarchive
        modify(["INBOX"], [] )
      end

      def unarchive!
        modify!(["INBOX"], [] )
      end

      def star
        modify(["STARRED"], [] )
      end

      def star!
        modify!(["STARRED"], [] )
      end

      def unstar
        modify([],["STARRED"] )
      end

      def unstar!
        modify!([],["STARRED"] )
      end

      def mark_as_read
        modify([],["UNREAD"] )
      end

      def mark_as_read!
        modify!([],["UNREAD"] )
      end

      def mark_as_unread
        modify(["UNREAD"],[] )
      end

      def mark_as_unread!
        modify!(["UNREAD"],[] )
      end

    end
  end
end