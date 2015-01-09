require_relative '../lib/test_compiler'
require 'ostruct'

describe TestCompiler do
  true_test = <<EOT
verdadero = true
EOT

  compiled_test_submission = <<EOT
verdadero = true
EOT

  describe '#compile' do
    let(:compiler) { TestCompiler.new(nil) }
    it { expect(compiler.compile(true_test, '')).to eq(compiled_test_submission) }
  end

  describe '#create_compilation_file!' do
    let(:compiler) { TestCompiler.new(nil) }
    let(:file) { compiler.create_compilation_file!('bar.', 'foo.') }

    it { expect(File.exists? file.path).to be true }
  end
end
