class QueryHook < Mumukit::Templates::FileHook
  isolated true
  structured true

  def tempfile_extension
    '.rb'
  end

  def compile_file_content(r)
    "#{r.extra}\n#{r.content}\nprint('=> ' + (#{r.query}).inspect)"
  end

  def command_line(filename)
    "ruby #{filename}"
  end
end