require 'tty-prompt'
require 'optparse'
require 'json'

require_relative 'laws/aws/base_helper'
require_relative 'laws/aws/ecs_helper'
require_relative 'laws/aws/secretsmanager_helper'
require_relative 'laws/commands/ecs'
require_relative 'laws/commands/secretsmanager'
require_relative 'laws/cli'

module Laws
end