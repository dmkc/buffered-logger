require "test_helper"

describe BufferedLogger do
  before do
    @buffer = StringIO.new
    @logger = BufferedLogger.new(@buffer)
  end

  it "should raise an error if end is called while not started" do
    @logger.stubs(:started?).returns(false)
    -> { @logger.end }.must_raise(BufferedLogger::NotStartedError)
  end

  it "should raise an error if start is called while already started" do
    @logger.stubs(:started?).returns(true)
    -> { @logger.start }.must_raise(BufferedLogger::AlreadyStartedError)
  end

  it "should not use the formatter for buffered messages" do
    @logger.formatter = -> (severity, _datetime, _progname, msg) {
      "[#{msg}]\n"
    }

    @logger.info('1')
    @logger.start
    @logger.info('2')
    @logger.info('3')
    @logger.end
    @logger.info('4')

    assert_equal "[1]\n[2\n3]\n[4]\n", @buffer.string
  end

  if defined?(ActiveSupport)
    it "only logs the string" do
      if defined?(ActiveSupport::Logger::SimpleFormatter)
        @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      end
      @logger.debug "foo"

      assert_equal "foo\n", @buffer.string
    end
  end
end
