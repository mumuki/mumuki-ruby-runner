require 'mumukit'

class TestCompiler
  def compile(test_src, content_src)
    <<EOF
require 'spec'
#{content_src}
#{test_src}
EOF
  end
end
