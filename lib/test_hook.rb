class RubyTestHook < Mumukit::Templates::FileHook
  mashup do |fields| 
    fields[2] = <<RUBY
describe do
  after(:all) do
    puts '!!!MUMUKI-RUBY-OUTPUT!!!'
  end
  #{fields[2]}
end
RUBY
    fields
  end
  isolated true
  structured true, separator: '!!!MUMUKI-RUBY-OUTPUT!!!'

  def tempfile_extension
    '.rb'
  end

  def command_line(filename)
    "rspec #{filename} -f json"
  end

  def to_structured_result(result)
    transform(super['examples'])
  end

  def transform(examples)
    examples.map { |e| [e['full_description'].strip, e['status'].to_sym, parse_out(e['exception'])] }
  end

  def parse_out(exception)
    exception ? exception['message'] : ''
  end
end
