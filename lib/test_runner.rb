class TestRunner < Mumukit::FileTestRunner
  def rspec_path
    config['rspec_command']
  end

  def run_test_command(file)
    "#{rspec_path} #{file.path} -f json 2>&1"
  end

  def post_process_file(file, result, status)
    [transform(JSON.parse(result)['examples']), status]
  end

  def transform(examples)
    examples.map { |e| {title: e['full_description'], exit: e['status'].to_sym, out: parse_out(e['exception']) } }
  end

  def parse_out(exception)
    if exception
      exception['message']
    else
      ''
    end
  end
end
