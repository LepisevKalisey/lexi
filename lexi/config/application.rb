# frozen_string_literal: true

# Evaluated inside Chatwoot::Application (config/application.rb) when lexi/ exists.
# Wires lexi/ the way config/application.rb wires enterprise/, which LEXI builds strip.

config.eager_load_paths << Rails.root.join('lexi/lib')
config.eager_load_paths += Dir[Rails.root.join('lexi/app/*').to_s].select { |path| File.directory?(path) }
config.paths['app/views'].unshift('lexi/app/views')
config.paths['config/initializers'] << 'lexi/config/initializers'
config.paths['config/locales'] << 'lexi/config/locales'

# Chatwoot Hub keeps relaying push notifications to the official mobile apps; LEXI only stops
# the usage metrics and events it would send. LEXI_TELEMETRY=true keeps upstream behaviour.
ENV['DISABLE_TELEMETRY'] = 'true' unless ENV.key?('DISABLE_TELEMETRY') || ENV.fetch('LEXI_TELEMETRY', nil) == 'true'
