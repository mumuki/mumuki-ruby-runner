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
