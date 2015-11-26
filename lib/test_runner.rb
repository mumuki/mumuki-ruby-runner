require 'docker'
require 'pathname'

class Mumukit::IsolatedEnvironment
  attr_accessor :container

  def configure!(*files)

    filenames = files.map { |it| File.absolute_path(it.path) }
    dirnames = filenames.map { |it| Pathname.new(it).dirname }

    binds = dirnames.map { |it| "#{it}:#{it}" }
    volumes = Hash[[dirnames.map { |it| [it, {}] }]]

    command = yield(*filenames).split

    self.container = Docker::Container.create(
        'Image' => Mumukit.config.docker_image,
        'Cmd' => command,
        'NetworkDisabled' => true,
        'HostConfig' => {
            #  'Memory' => Mumukit.config.command_size_limit,
            'Binds' => binds},
        'Volumes' => volumes)
  end

  def run!
    container.start
    container.wait(Mumukit.config.command_time_limit)

    exit = container.json['State']['ExitCode']
    out = container.streaming_logs(stdout: true, stderr: true)

    if exit == 0
      [out, :passed]
    else
      [out, :failed]
    end
  rescue Docker::Error::TimeoutError => e
    [I18n.t('mumukit.time_exceeded', limit: Mumukit.config.command_time_limit), :aborted]
  end

  def destroy!
    if container
      container.stop
      container.delete
    end
  end
end

module Mumukit
  module WithIsolatedEnvironment
    def run_test_file!(file)
      env = Mumukit::IsolatedEnvironment.new
      env.configure!(file) { |filename| run_test_command(filename) }
      env.run!
    ensure
      env.destroy!
    end

    def run_test_command(file)
      raise 'You need to implement this method'
    end
  end
end

module Mumukit
  module WithEmbeddedEnvironment
    extend Mumukit::WithCommandLine

    def run_test_file!(file)
      run_command run_test_command(file.path)
    end

    def run_test_command(file)
      raise 'You need to implement this method'
    end
  end
end


class TestRunner < Mumukit::FileTestRunner
  include Mumukit::WithIsolatedEnvironment

  def rspec_path
    config['rspec_command']
  end

  def run_test_command(filename)
    "#{rspec_path} #{filename} -f json"
  end

  def post_process_file(file, result, status)
    if [:passed, :failed].include? status
      [transform(JSON.parse(result)['examples'])]
    else
      [result, status]
    end
  rescue JSON::ParserError
    [result, :errored]
  end

  def transform(examples)
    examples.map { |e| [e['full_description'], e['status'].to_sym, parse_out(e['exception'])] }
  end

  def parse_out(exception)
    if exception
      exception['message']
    else
      ''
    end
  end
end
