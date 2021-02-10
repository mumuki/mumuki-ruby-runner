require_relative './spec_helper'


describe 'running' do
  let(:runner) { RubyTestHook.new('rspec_command' => 'rspec') }

  let(:file) { runner.compile(OpenStruct.new(content: content, test: test, extra: extra)) }
  let(:raw_results) { runner.run!(file) }
  let(:results) { raw_results[0] }

  let(:extra) {''}

  let(:content) do
    '_true = true'
  end

  describe '#run!' do
    context 'on simple passed file' do
      let(:test) do 
        <<RUBY
describe '_true' do
  it 'is true' do
    expect(_true).to eq true
  end
end
RUBY
      end

      it { expect(results).to eq([['_true is true', :passed, '']]) }
    end

    context 'on simple passed file with sets' do
      let(:test) do
        <<RUBY
describe 'empty set' do
  it 'is empty set' do
    expect(Set.new).to eq Set.new
  end
end
RUBY
      end

      it { expect(results).to eq([['empty set is empty set', :passed, '']]) }
    end

    context 'on simple failed file' do
      let(:test) do 
        <<RUBY
describe '_true' do
  it 'is something that will fail' do
    expect(_true).to eq 3
  end
end
RUBY
      end

      it { expect(results).to(
          eq([['_true is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end

    context 'on multi file' do
      let(:test) do 
        <<RUBY
describe '_true' do
  it 'is true' do
    expect(_true).to eq true
  end

  it 'is not _false' do
    expect(_true).to_not eq false
  end

  it 'is something that will fail' do
    expect(_true).to eq 3
  end
end
RUBY
      end

      it { expect(results).to(
          eq([['_true is true', :passed, ''],
              ['_true is not _false', :passed, ''],
              ['_true is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end

    context 'on logging operation' do
      let(:test) do 
        <<RUBY
describe '_true' do
  it 'is something that will fail' do
    puts 'An Output.'
    expect(_true).to eq 3
  end
end
RUBY
      end

      it { expect(results).to(
          eq([['_true is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end
  end
end
