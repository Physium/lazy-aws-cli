module Laws
    class CLI
      def initialize
        @options = {}
        @ecs_helper = AWS::ECSHelper.new
        @secrets_helper = AWS::SecretsHelper.new
        @prompt = TTY::Prompt.new
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
        case command
        when 'ecs execute-command'
          execute
        when 'secretsmanager get-secret-value'
          get_secret_value
        when nil, ''
          puts "No command specified. Use --help for usage information."
          exit 1
        else
          puts "Unknown command: #{command}"
          exit 1
        end
      end
  
      private
  
      def prompt_for_command
        @prompt.ask("Enter command to execute (press Enter for default /bin/sh):") do |q|
          q.default "/bin/sh"
          q.modify :strip
        end
      end
  
      def execute
        # List and select cluster
        clusters = @ecs_helper.list_clusters
        if clusters.empty?
          puts "No clusters found in the account."
          return
        end
  
        selected_cluster = @prompt.select("Select a cluster:", clusters)
  
        # List and select task
        tasks = @ecs_helper.list_tasks(selected_cluster)
        if tasks.empty?
          puts "No running tasks found in cluster #{selected_cluster}"
          return
        end
  
        task_choices = @ecs_helper.create_task_choices(tasks)
        selected_task = @prompt.select("Select a task:", task_choices)
        task_id = selected_task.task_arn.split('/').last
  
        # Select container if multiple containers exist
        container_names = @ecs_helper.get_container_names(selected_task)
        selected_container = if container_names.length > 1
                             @prompt.select("Select a container:", container_names)
                           else
                             container_names.first
                           end
  
        # Get command from option or prompt
        command = @options[:command] || prompt_for_command
  
        # Construct and execute the AWS CLI command
        aws_command = [
          "aws", "ecs", "execute-command",
          "--cluster", selected_cluster,
          "--task", task_id,
          "--container", selected_container,
          "--interactive",
          "--command", command
        ].join(" ")
  
        puts "\nExecuting command:"
        puts "#{aws_command}\n"
  
        begin
          system(aws_command)
        rescue Interrupt
          puts "\nOperation cancelled by user"
        rescue StandardError => e
          puts "Error executing command: #{e.message}"
        end
      end
  
      def get_secret_value
        secrets = @secrets_helper.list_secrets
        if secrets.empty?
          puts "No secrets found in the account."
          return
        end
  
        selected_secret = @prompt.select("Select a secret:", secrets)
        secret_value = @secrets_helper.get_secret_value(selected_secret)
  
        puts "\nSecret value:"
        if secret_value.is_a?(Hash)
          secret_value.each { |key, value| puts "#{key}: #{value}" }
        else
          puts secret_value
        end
      end
    end
  end