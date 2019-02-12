class RubyQueryHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.rb'
  end

  def compile_file_content(r)
    <<ruby
    class MumukiConsole
      def self.write(string)
      end
      def self.enter_cookie!
        @@old_stdout = $stdout
        $stdout = MumukiConsole
      end
      def self.exit_cookie!
        $stdout = @@old_stdout
      end
    end
    #{r.extra}
    #{r.content}
    MumukiConsole.enter_cookie!
    #{compile_cookie(r.cookie)}
    MumukiConsole.exit_cookie!
    #{compile_query(r.query)}
ruby
  end

  def command_line(filename)
    "ruby #{filename}"
  end

  def post_process_file(_file, result, status)
    if status == :failed && runtime_error_output?(result)
      [sanitize_runtime_error_output(result), status]
    elsif status == :failed && syntax_error_output?(result)
      [sanitize_syntax_error_output(result), :errored]
    else
      super
    end
  end

  def compile_query(query)
    if query.start_with? 'def '
      "#{query}\nputs \"=> nil\""
    else
      "puts('=> ' + (#{query}).inspect)"
    end
  end

  def build_state(cookie)
    (cookie||[]).map do |statement|
    <<ruby
  begin
    #{statement}
  rescue
  end
ruby
    end
  end

  def compile_cookie(cookie)
    build_state(cookie).join("\n")
  end

  def runtime_error_output?(result)
    runtime_error_regexp === result
  end

  def syntax_error_output?(result)
    syntax_error_regexp === result
  end

  def sanitize_runtime_error_output(result)
    result.gsub(runtime_error_regexp, '').strip
  end

  def sanitize_syntax_error_output(result)
    result.gsub(syntax_error_regexp, '').strip
  end

  def runtime_error_regexp
    # Matches lines like:
    # * from /tmp/mumuki.compile20170404-3221-1db8ntk.rb:17:in `<main>'
    # * /tmp/mumuki.compile20170404-3221-1db8ntk.rb:17:in `respond_to?':
    /(from )?(.)+\.rb:(\d)+:in `([\w|<|>|?|!|+|*|-|\/|=]+)'(:)?/
  end

  def syntax_error_regexp
    /.+?\.rb:\d+: (?m)(?=.*syntax error)/
  end
end
