module Laws
  module AWS
    class BaseHelper
      def initialize
        check_credentials!
      end

      private

      def check_credentials!
        config = `aws configure list`
        config_lines = config.split("\n")

        missing_vars = []
        config_lines.each do |line|
          if line.include?('access_key') && line.include?('<not set>')
            missing_vars << 'access_key'
          elsif line.include?('secret_key') && line.include?('<not set>')
            missing_vars << 'secret_key'
          elsif line.include?('region') && line.include?('<not set>')
            missing_vars << 'region'
          end
        end

        return if missing_vars.empty?

        puts "\n⚠️ AWS credentials not found!"
        puts "\nPlease either:"
        puts "1. Run 'aws configure' to set up your AWS credentials"
        puts '2. Or set the following environment variables:'
        missing_vars.each do |var|
          puts "     export #{var.upcase}=your_#{var}"
        end
        puts "\nFor more information, visit: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html"
        exit 1
      end
    end
  end
end
