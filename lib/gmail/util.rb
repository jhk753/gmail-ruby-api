module Gmail
  module Util

    def self.object_classes
      @object_classes ||= {
          # data structures

          # business objects
          'draft' => Draft,
          'label' => Label,
          'message' => Message,
          'thread' => Thread
      }
    end

    def self.convert_to_gmail_object(resp, key=nil)
      case resp
        when Array
          resp.map { |i| convert_to_gmail_object(i, key) }
        when Hash
          # Try converting to a known object class.  If none available, fall back to generic StripeObject
          object_classes.fetch(key , GmailObject).new(resp)
        else
          resp
      end
    end


    def self.symbolize_names(object)
      case object
        when Hash
          new_hash = {}
          object.each do |key, value|
            key = (key.to_sym rescue key) || key
            new_hash[key] = symbolize_names(value)
          end
          new_hash
        when Array
          object.map { |value| symbolize_names(value) }
        else
          object
      end
    end
  end
end