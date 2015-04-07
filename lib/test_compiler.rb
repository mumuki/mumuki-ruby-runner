require 'mumukit'

class TestCompiler
  def compile(test_src, extra_src, content_src)
    <<EOF
#{extra_src}
#{content_src}
#{test_src}
EOF
  end
end
