require 'mumukit'

class TestRunner
  def rspec_path
    @config['rspec_command']
  end

  def run_test_file!(file)
    validate_compile_errors(file, *super)
  end

  def validate_compile_errors(file, result, status)
    if /ERROR: #{file.path}:.*: Syntax error: .*/ =~ result
      [result, :failed]
    else
      [result, status]
    end
  end

  def run_test_command(file)
    "#{rspec_path} #{file.path} 2>&1"
  end

end
