require 'docker'
require 'pathname'

class TestSandbox
  attr_accessor :container

  def configure!(file)
    filename = File.absolute_path file.path
    pathname = Pathname.new(filename)

    self.container = Docker::Container.create(
        'Image' => 'abdd878dd50a',
        'Cmd' => ['rspec', "#{filename}", '-f', 'json'],
        'HostConfig' => {
            'Binds' => ["#{pathname.dirname}:#{pathname.dirname}"]},
        'Volumes' => {
            pathname.dirname => {}})
  end

  def run!
    container.start
    container.wait(Mumukit.config.command_time_limit)
  end

  def destroy!
    container.stop
    container.delete
  end

  def exit_code
    container.json['State']['ExitCode']
  end

  def out
    container.streaming_logs(stdout: true, stderr: true)
  end

end

class TestRunner < Mumukit::FileTestRunner
  def rspec_path
    config['rspec_command']
  end

  def run_test_file!(file)
    sandbox = TestSandbox.new
    sandbox.configure! file
    sandbox.run!

    exit = sandbox.exit_code
    out = sandbox.out

    if exit == 0
      [out, :passed]
    else
      [out, :failed]
    end
  rescue Docker::Error::TimeoutError => e
    [I18n.t('mumukit.time_exceeded', limit: Mumukit.config.command_time_limit), :aborted]
  ensure
    sandbox.destroy!
  end

  #------------------


  def post_process_file(file, result, status)
    [transform(JSON.parse(result)['examples'])]
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
