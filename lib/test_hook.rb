class RubyTestHook < Mumukit::Templates::FileHook
  line_number_offset 2, include_extra: true

  mashup do |extra, content, test|
    [extra,
    content,
<<RUBY
describe do
  after(:all) do
    puts '!!!MUMUKI-RUBY-OUTPUT!!!'
  end
  #{test}
end
RUBY
    ]
  end
  isolated true
  structured true, separator: '!!!MUMUKI-RUBY-OUTPUT!!!'

  def tempfile_extension
    '.rb'
  end

  def command_line(filename)
    "rspec #{filename} -f json"
  end

  def post_process_unstructured_result(file, result, status)
    if status.errored?
      [
        result
          .gsub(/^.*(solution.rb:\d+:)/) { $1 }
          .lines
          .reject { |it| it.start_with? "	from /usr/local" }
          .take(3)
          .join + "\n",
        status
      ]
    else
      super
    end
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
