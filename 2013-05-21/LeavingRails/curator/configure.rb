require 'curator'

Curator.configure(:mongo) do |config|
  config.database = 'curator'
  config.environment = 'development'
  config.migrations_path = File.expand_path(__dir__ + "/migrations")
  config.mongo_config_file = File.expand_path(__dir__ + '/mongo.yml')
end
