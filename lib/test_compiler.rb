require 'mumukit'

class TestCompiler
  def compile(test_src, content_src)
    <<EOF
#{content_src}
#{test_src}
EOF
  end
end
