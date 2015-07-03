class TestCompiler < Mumukit::FileTestCompiler
  def compile(request)
    <<EOF
#{request.extra}
#{request.content}
#{request.test}
EOF
  end
end
