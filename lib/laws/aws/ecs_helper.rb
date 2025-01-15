require 'aws-sdk-ecs'

module Laws
  module AWS
    class ECSHelper < BaseHelper
      def initialize
        super
        @ecs_client = Aws::ECS::Client.new
        @prompt = TTY::Prompt.new
      end

      def list_clusters
        clusters = []
        next_token = nil

        loop do
          response = @ecs_client.list_clusters(next_token: next_token)
          clusters.concat(response.cluster_arns.map { |arn| arn.split('/').last })
          next_token = response.next_token
          break unless next_token
        end

        clusters
      end

      def list_tasks(cluster_name)
        tasks = []
        next_token = nil

        loop do
          response = @ecs_client.list_tasks(cluster: cluster_name, next_token: next_token)

          unless response.task_arns.empty?
            task_details = @ecs_client.describe_tasks(
              cluster: cluster_name,
              tasks: response.task_arns
            )
            tasks.concat(task_details.tasks)
          end

          next_token = response.next_token
          break unless next_token
        end

        tasks
      end

      def get_container_names(task)
        task.containers.map(&:name)
      end

      def create_task_choices(tasks)
        tasks.map do |task|
          task_id = task.task_arn.split('/').last
          task_def = task.task_definition_arn.split('/').last
          display = "#{task_id} (#{task_def})"
          { name: display, value: task }
        end
      end
    end
  end
end 