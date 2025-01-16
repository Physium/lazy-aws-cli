module Laws
  module Commands
    class SecretsManager
      def initialize(secretsmanager_helper, prompt)
        @secretsmanager_helper = secretsmanager_helper
        @prompt = prompt
      end

      def get_secret_value
        secrets = @secretsmanager_helper.list_secrets
        if secrets.empty?
          puts "No secrets found in the account."
          return
        end

        selected_secret = @prompt.select("Select a secret:", secrets)
        secret_value = @secretsmanager_helper.get_secret_value(selected_secret)

        puts "\nSecret value:"
        if secret_value.is_a?(Hash)
          secret_value.each { |key, value| puts "#{key}: #{value}" }
        else
          puts secret_value
        end
      end
    end
  end
end 