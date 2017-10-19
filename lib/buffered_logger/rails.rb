require "buffered_logger"
require "rails"

class BufferedLogger
  class Railtie < Rails::Railtie
    config.buffered_logger = ActiveSupport::OrderedOptions.new
    config.buffered_logger.stdout = false

    initializer :buffered_logger, :before => :initialize_logger do |app|
      next if app.config.logger

      if Rails::VERSION::STRING >= "3.1"
        path = app.paths["log"].first
      else
        path = app.paths.log.to_a.first
      end

      file = if app.config.buffered_logger.stdout
        STDOUT
      else
        File.open(path, "a")
      end

      file.binmode
      file.sync = true

      app.config.logger = BufferedLogger.new(file, json: app.config.buffered_logger.json_logging)
      app.config.logger.formatter = app.config.log_formatter
      app.config.logger.level = BufferedLogger.const_get(app.config.log_level.to_s.upcase)
      app.config.middleware.insert(0, BufferedLogger::Middleware, app.config.logger)
    end
  end
end
