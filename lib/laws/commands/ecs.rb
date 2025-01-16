module Laws
  module Commands
    class ECS
      def initialize(prompt)
        @prompt = prompt
      end

      def execute_command
        selected_cluster = select_cluster
        return if selected_cluster.nil?

        selected_task = select_task(selected_cluster)
        return if selected_task.nil?

        task_id = selected_task.task_arn.split('/').last
        selected_container = select_container(selected_task)
        command = prompt_for_command

        execute_aws_command(selected_cluster, task_id, selected_container, command)
      end

      private

      def aws_helper
        @aws_helper ||= AWS::ECSHelper.new
      end

      def select_cluster
        clusters = aws_helper.list_clusters
        if clusters.empty?
          puts "No clusters found in the account."
          return nil
        end

        @prompt.select("Select a cluster:", clusters)
      end

      def select_task(cluster)
        tasks = aws_helper.list_tasks(cluster)
        if tasks.empty?
          puts "No running tasks found in cluster #{cluster}"
          return nil
        end

        task_choices = aws_helper.create_task_choices(tasks)
        @prompt.select("Select a task:", task_choices)
      end

      def select_container(task)
        container_names = aws_helper.get_container_names(task)
        if container_names.length > 1
          @prompt.select("Select a container:", container_names)
        else
          container_names.first
        end
      end

      def prompt_for_command
        @prompt.ask("Enter command to execute (press Enter for default /bin/sh):") do |q|
          q.default "/bin/sh"
          q.modify :strip
        end
      end

      def execute_aws_command(cluster, task_id, container, command)
        aws_command = [
          "aws", "ecs", "execute-command",
          "--cluster", cluster,
          "--task", task_id,
          "--container", container,
          "--interactive",
          "--command", command
        ].join(" ")

        puts "\nExecuting command:"
        puts "#{aws_command}\n"

        begin
          exec(aws_command)
        rescue StandardError => e
          puts "Error executing command: #{e.message}"
        end
      end
    end
  end
end 