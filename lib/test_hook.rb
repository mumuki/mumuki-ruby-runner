class RubyTestHook < Mumukit::Templates::FileHook
  mashup
  isolated true
  structured true

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
    examples.map { |e| [e['full_description'], e['status'].to_sym, parse_out(e['exception'])] }
  end

  def parse_out(exception)
    exception ? exception['message'] : ''
  end
end
