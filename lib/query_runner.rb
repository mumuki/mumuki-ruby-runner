class QueryRunner <Mumukit::Stub
  include Mumukit::WithTempfile
  include Mumukit::WithCommandLine


  def run_query!(request)
     eval_query compile_query(request)
  end

  def compile_query(r)
    "#{r.extra}\n#{r.content}\nprint('=> ' + (#{r.query}).inspect)"
  end

  def eval_query(r)
    f = write_tempfile! r
    run_command "ruby < #{f.path}"
  ensure
    f.unlink
  end
end