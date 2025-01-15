module Laws
  module AWS
    class BaseHelper
      def initialize
        check_aws_configuration!
      end

      private

      def check_aws_configuration!
        missing_vars = []
        required_vars = {
          'AWS_ACCESS_KEY_ID' => ENV['AWS_ACCESS_KEY_ID'],
          'AWS_SECRET_ACCESS_KEY' => ENV['AWS_SECRET_ACCESS_KEY'],
          'AWS_REGION' => ENV['AWS_REGION']
        }

        required_vars.each do |var, value|
          missing_vars << var if value.nil? || value.empty?
        end

        if !missing_vars.empty? && !File.exist?(File.expand_path('~/.aws/credentials'))
          puts "\n⚠️  AWS configuration not found!"
          puts "\nPlease either:"
          puts "1. Run 'aws configure' to set up your AWS credentials"
          puts "2. Or set the following environment variables:"
          missing_vars.each do |var|
            puts "   export #{var}=your_#{var.downcase}"
          end
          puts "\nFor more information, visit: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html"
          exit 1
        end
      end
    end
  end
end 