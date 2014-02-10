require "atalanda/signature/version"
require "digest"

module Atalanda
  module Signature
    class Token
      attr_accessor :api_key, :api_secret

      def initialize(app_api_key, app_api_secret)
        self.api_key=app_api_key
        self.api_secret=app_api_secret
      end
    end 

    class Request
      def initialize(method, path, parameters, time=Time.now)
        @method = method.upcase
        @path = path
        @parameters = parameters
        @time = time.to_i
      end

      def sign(token)
        param_string = buildParameterString()
        signature = calculateSignature(token, param_string, @time)
        @parameters.merge!({
          "auth_timestamp" => @time,
          "auth_key" => token.api_key,
          "auth_signature" => signature
        })
      end

      def authenticate token, timestamp_grace=600
        if get_auth_hash.nil?
          return {
            "authenticated" => false,
            "reason" => "Auth hash is missing"
          }
        end

        if (@time - get_auth_hash["auth_timestamp"].to_i).abs > timestamp_grace
          return {
            "authenticated" => false,
            "reason" => "Auth timestamp is older than #{timestamp_grace} seconds"
          }
        end

        recalculated_signature = calculateSignature(token, buildParameterString(), get_auth_hash["auth_timestamp"])
        if recalculated_signature != get_auth_hash["auth_signature"]
          return {
            "authenticated" => false,
            "reason" => "Signature does not match"
          }
        end

        {
          "authenticated" => true
        }
      end

      private

        def get_auth_hash
          if @parameters.has_key?("auth_key") && @parameters.has_key?("auth_signature") && @parameters.has_key?("auth_timestamp")
            return {
              "auth_timestamp" => @parameters["auth_timestamp"],
              "auth_key" => @parameters["auth_key"],
              "auth_signature" => @parameters["auth_signature"]
            }
          else
            return nil
          end
        end

        def calculateSignature token, string, time
          Digest::SHA256.hexdigest("#{string}#{token.api_key}#{token.api_secret}#{time}")
        end

        def buildParameterString
          "#{@method}#{@path}#{canonical_string_from_hash(@parameters)}"
        end

        def canonical_string_from_hash value, key=nil
          str = ""
          return "" if key == "auth_key" || key == "auth_timestamp" || key == "auth_signature"

          if value.is_a? Hash
            str += key.to_s
            value.keys.sort.each do |k|
              str += canonical_string_from_hash(value[k], k)
            end
          elsif value.is_a? Array
            str += key.to_s
            value.each do |v|
              str += canonical_string_from_hash(v)
            end
          else
            str += key ? "#{key}#{value}" : value.to_s
          end
          return str
        end
    end
  end
end
