class TestRunner < Mumukit::FileTestRunner
  def rspec_path
    config['rspec_command']
  end

  def run_test_command(file)
    "#{rspec_path} #{file.path} 2>&1"
  end

end
