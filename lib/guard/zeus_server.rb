require 'guard'
require 'guard/guard'
require 'guard/zeus_server/version'

module Guard
  class ZeusServer < Guard
    autoload :Runner, 'guard/zeus_server/runner'
    attr_accessor :options, :runner

    DEFAULT_OPTIONS = {
      :port => 3000,
      :command => "server"
    }

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super
      self.options = DEFAULT_OPTIONS.merge(options)
      self.runner = Runner.new self.options
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      UI.info "starting!"
      runner.start
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
      UI.info "stopping!"
      runner.stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
      UI.info "reloading!"
      runner.restart
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_changes(paths)
      reload
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_removals(paths)
      reload
    end
  end
end
