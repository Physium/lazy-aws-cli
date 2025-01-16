module Laws
  module Commands
    class SecretsManager
      def initialize(prompt)
        @prompt = prompt
      end

      def get_secret_value # rubocop:disable Naming/AccessorMethodName
        secrets = aws_helper.list_secrets
        if secrets.empty?
          puts 'No secrets found in the account.'
          return
        end

        selected_secret = @prompt.select('Select a secret:', secrets)
        secret_value = aws_helper.get_secret_value(selected_secret)

        puts "\nSecret value:"
        if secret_value.is_a?(Hash)
          secret_value.each { |key, value| puts "#{key}: #{value}" }
        else
          puts secret_value
        end
      end

      private

      def aws_helper
        @aws_helper ||= AWS::SecretsManagerHelper.new
      end
    end
  end
end
