require 'docker'
require 'pathname'

class TestRunner < Mumukit::FileTestRunner
  def rspec_path
    config['rspec_command']
  end

  def run_test_file!(file)
    container = create_container(file)

    run_container(container)

    exit = container.json['State']['ExitCode']
    logs = container.streaming_logs(stdout: true, stderr: true)

    if exit == 0
      [logs, :passed]
    else
      [logs, :failed]
    end
  rescue Docker::Error::TimeoutError => e
    [I18n.t('mumukit.time_exceeded', limit: Mumukit.config.command_time_limit), :aborted]
  ensure
    destroy_container(container)
  end

  def destroy_container(container)
    container.stop
    container.delete
  end

  def create_container(file)
    filename = File.absolute_path file.path
    pathname = Pathname.new(filename)

    Docker::Container.create(
        'Image' => 'abdd878dd50a',
        'Cmd' => ['rspec', "#{filename}", '-f', 'json'],
        'HostConfig' => {
            'Binds' => ["#{pathname.dirname}:#{pathname.dirname}"]},
        'Volumes' => {
            pathname.dirname => {}})
  end

  def run_container(container)
    container.start
    container.wait(Mumukit.config.command_time_limit)
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
