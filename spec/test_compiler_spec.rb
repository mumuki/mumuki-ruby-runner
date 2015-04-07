require_relative '../lib/test_compiler'
require 'ostruct'

describe TestCompiler do
  true_test = <<EOT
describe '_true' do
  it 'is true' do
    expect(_true).to be true
  end
end
EOT

  true_submission = <<EOT
_true  = true
EOT

  compiled_test_submission = <<EOT
_false = false
_true  = true

describe '_true' do
  it 'is true' do
    expect(_true).to be true
  end
end

EOT

  describe '#compile' do
    let(:compiler) { TestCompiler.new(nil) }
    it { expect(compiler.compile(true_test, '_false = false', true_submission)).to eq(compiled_test_submission) }
  end

end
