module Laws
  class CLI
    def initialize
      @prompt = TTY::Prompt.new
      @ecs = Commands::ECS.new(@prompt)
      @secretsmanager = Commands::SecretsManager.new(@prompt)
    end

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: laws [command]"

        opts.on('-h', '--help', 'Display this help message') do
          puts opts
          exit
        end

        opts.separator "\nCommands:"
        opts.separator "  ecs execute-command    Run interactive ECS execute-command"
        opts.separator "  secretsmanager get-secret-value  Get and display secret value"
      end.parse!

      # Handle commands
      command = ARGV.join(' ')  # Join arguments to handle multi-word commands
      begin
        case command
        when 'ecs execute-command'
          @ecs.execute_command
        when 'secretsmanager get-secret-value'
          @secretsmanager.get_secret_value
        when nil, ''
          puts "No command specified. Use --help for usage information."
          exit 1
        else
          puts "Unknown command: #{command}"
          exit 1
        end
      rescue TTY::Reader::InputInterrupt
        puts "\nOperation cancelled."
        exit 1
      end
    end
  end
end