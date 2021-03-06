require 'spec_helper'
require 'guard/zeus_server/runner'
require 'fakefs/spec_helpers'

describe Guard::ZeusServer::Runner do
  include FakeFS::SpecHelpers
  let(:options) { { :port => 3000, :command => "server" } }
  let(:runner) { Guard::ZeusServer::Runner.new(options) }
  let(:pid_file) { File.expand_path("tmp/pids/zeus_server.pid") }

  before do
    FileUtils.mkdir_p "/project"
    Dir.chdir "/project"
    runner.stub :system
  end

  describe "#start" do
    before do
      runner.stub(:wait_until) { true }
    end
    it "should start zeus server" do
      runner.should_receive(:system).with("cd /project; zeus server -d -p 3000 -P #{pid_file}")

      runner.start
    end

    it "should set the pid" do
      command_should_include(" -P #{pid_file}")

      runner.start
    end

    it "should be daemonized" do
      command_should_include(" -d")

      runner.start
    end

    it "should let you change the port" do
      options[:port] = 1234
      command_should_include(" -p 1234")

      runner.start
    end

    it "should delete the pidfile if it's not running" do
      create_pid_file(54444)
      runner.stub(:system).with("kill -0 54444") { false }

      runner.start
      File.file?(pid_file).should_not be
    end

    it "should not start the server if it is already running" do
      create_pid_file(54444)
      runner.stub(:system).with("kill -0 54444") { true }
      runner.should_not_receive(:system).with do |command|
        command =~ /zeus/
      end

      runner.start
    end
  end

  describe "#stop" do
    it "should kill an existing pid" do
      create_pid_file(54444)

      runner.should_receive(:system).with("kill -SIGINT 54444") do
        FileUtils.rm pid_file
      end
      runner.stub(:system).with("kill 0 54444") { false }

      runner.stop
    end
  end

  describe "#restart" do
    it "should stop then start" do
      runner.should_receive(:stop).ordered
      runner.should_receive(:start).ordered

      runner.restart
    end
  end

  def command_should_include(part)
    runner.should_receive(:system).with do |command|
      command.should match /#{part}\b/
    end
  end

  def create_pid_file(pid)
    FileUtils.mkdir_p File.dirname(pid_file)
    File.open(pid_file, 'w') { |file| file.print pid }
  end
end
