require 'mumukit'

class TestCompiler
  def compile(test_src, content_src)
    <<EOF
#{test_src}
#{content_src}
EOF
  end
end
