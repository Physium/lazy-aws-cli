require 'aws-sdk-secretsmanager'

module Laws
  module AWS
    class SecretsManagerHelper < BaseHelper
      def initialize
        super
        @secretsmanager_client = Aws::SecretsManager::Client.new
      end

      def list_secrets
        secrets = []
        next_token = nil

        loop do
          response = @secretsmanager_client.list_secrets(next_token: next_token)
          secrets.concat(response.secret_list.map(&:name))
          next_token = response.next_token
          break unless next_token
        end

        secrets
      end

      def get_secret_value(secret_name)
        response = @secretsmanager_client.get_secret_value(secret_id: secret_name)

        if response.secret_string
          begin
            JSON.parse(response.secret_string)
          rescue JSON::ParserError
            response.secret_string
          end
        else
          response.secret_binary.unpack1('m')
        end
      rescue Aws::SecretsManager::Errors::ServiceError => e
        puts "Error retrieving secret: #{e.message}"
        exit 1
      end
    end
  end
end
