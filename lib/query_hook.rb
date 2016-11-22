class RubyQueryHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.rb'
  end

  def compile_file_content(r)
    <<ruby
    #{r.extra}
    #{r.content}
    #{compile_cookie(r.cookie)}
    #{compile_query(r.query)}
ruby
  end

  def command_line(filename)
    "ruby #{filename}"
  end

  def compile_query(query)
    if query.start_with? 'def '
      "#{query}\nputs \"<function>\""
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

end
