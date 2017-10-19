require 'logger'

class BufferedLogger < ::Logger
  require "buffered_logger/errors"
  require "buffered_logger/log_device_proxy"
  require "buffered_logger/middleware"
  require "buffered_logger/version"

  def initialize(*)
    super
    @logdev = LogDeviceProxy.new(@logdev)
  end

  def end
    raise NotStartedError, "not started" unless started?
    message = @logdev.end
    write_formatted(message)
    nil
  end

  def flush
    write_formatted(@logdev.flush)
  end

  def start(&block)
    raise AlreadyStartedError, "already started" if started?
    @logdev.start

    if block_given?
      begin
        yield
      ensure
        self.end
      end
    else
      true
    end
  end

  def started?
    @logdev.started?
  end

  def current_log
    @logdev.current_log
  end

  private
  def format_message(severity, datetime, progname, msg)
    if started?
      msg
    else
      super(severity, datetime, progname, msg)
    end
  end

  def write_formatted(message)
    @logdev.write(
      format_message(
        nil, Time.now, @progname, message
      )
    ) unless message.empty?
  end
end
