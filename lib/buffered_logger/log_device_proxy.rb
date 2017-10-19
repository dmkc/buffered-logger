require "thread"

class BufferedLogger
  class LogDeviceProxy
    THREAD_LOCAL_VAR_NAME = :"BufferedLogger::LogDeviceProxy::string_io"

    def initialize(logdev)
      @logdev = logdev
      destroy_thread_local
    end

    def close
      @logdev.close
    end

    def end
      result = string_io.string
      destroy_thread_local
      result.chop
    end

    def flush
      output = self.end
      start
      output
    end

    def start
      self.string_io = StringIO.new
    end

    def started?
      !!string_io
    end

    def write(message)
      if started?
        string_io << message.to_s + "\n"
      else
        @logdev.write(message)
      end
    end

    def current_log
      string_io.string.dup
    end

    private
    def string_io
      Thread.current[:string_io]
    end

    def string_io=(string_io)
      Thread.current[:string_io] = string_io
    end

    def destroy_thread_local
      self.string_io = nil
    end
  end
end
