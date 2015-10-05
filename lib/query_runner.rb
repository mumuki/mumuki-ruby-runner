class QueryRunner <Mumukit::Stub
  include Mumukit::WithTempfile
  include Mumukit::WithCommandLine


  def run_query!(request)
    begin
      result= eval_query compile_query(request)
    rescue #Exception.new('Something went wrong, check that your query is correct')
      result="Something went Wrong, Check that the sintax you have entered is correct"
    end
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