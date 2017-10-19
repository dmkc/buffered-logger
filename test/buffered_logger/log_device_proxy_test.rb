require "test_helper"

describe BufferedLogger::LogDeviceProxy do
  before do
    @logdev = mock()
    @proxy = BufferedLogger::LogDeviceProxy.new(@logdev)
  end

  it "should call write" do
    @logdev.expects(:write)
    @proxy.write("message")
  end

  it "should call close on the logdev when close is called" do
    @logdev.expects(:close)
    @proxy.close
  end

  it "should not call write on the logdev once started" do
    @logdev.expects(:write).never
    @proxy.start
    @proxy.write("message")
  end

  it "should be started? once started" do
    @proxy.start
    assert @proxy.started?
  end

  it "should buffer all writes and write them once" do
    @proxy.start
    @proxy.write("1")
    @proxy.write("2")
    @proxy.write("3")
    assert_equal "1\n2\n3", @proxy.end
  end

  it "should add newlines to buffered messages except the last one" do
    @proxy.start
    @proxy.write("1")
    @proxy.write("2")
    @proxy.write("3")
    assert_equal "1\n2\n3", @proxy.flush
  end

  it "should flush the buffered log and then start buffering again" do
    @proxy.start
    @proxy.write("1")
    @proxy.write("2")
    assert_equal "1\n2", @proxy.flush
    @proxy.write("3")
    assert_equal "3\n", @proxy.current_log
  end

  it "should allow access to the current buffer in string form" do
    @proxy.start
    @proxy.write("1")
    @proxy.write("2")
    assert_equal "1\n2\n", @proxy.current_log
  end
end
