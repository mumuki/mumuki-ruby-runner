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
    if status == :failed && error_output?(result)
      [sanitize_error_output(result), status]
    else
      super
    end
  end

  def compile_query(query)
    if query.start_with? 'def '
      "#{query}\nputs \"=> nil\""
    else
      "print('=> ' + (#{query}).inspect)"
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

  def error_output?(result)
    error_regexp =~ result
  end

  def sanitize_error_output(result)
    result.gsub(error_regexp, '').strip
  end

  def error_regexp
    # Matches lines like:
    # * from /tmp/mumuki.compile20170404-3221-1db8ntk.rb:17:in `<main>'
    # * /tmp/mumuki.compile20170404-3221-1db8ntk.rb:17:in `respond_to?':
    /(from )?(.)+\.rb:(\d)+:in `([\w|<|>|?|!|+|*|-|\/|=]+)'(:)?/
  end
end
