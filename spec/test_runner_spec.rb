require_relative '../lib/test_runner'

describe TestRunner do
  let(:runner) { TestRunner.new({'rspec_command' => 'rspec'}) }
  let(:file) { OpenStruct.new(path: '/tmp/foo.rb') }

  describe '#run_test_command' do
    it { expect(runner.run_test_command(file)).to include('rspec /tmp/foo.rb') }
    it { expect(runner.run_test_command(file)).to include('2>&1') }
  end

  describe '#validate_compile_errors' do
    let(:results) { runner.validate_compile_errors(file, *original_results) }

    describe 'fails on test errors' do
      let(:original_results) { ['Test failed', :failed] }
      it { expect(results).to eq(original_results) }
    end

    describe 'fails on compile errors ' do
      let(:original_results) { ['ERROR: /tmp/foo.rb:3:0: Syntax error: Operator expected', :passed] }
      it { expect(results).to eq(['ERROR: /tmp/foo.rb:3:0: Syntax error: Operator expected', :failed]) }
    end

    describe 'passes otherwise' do
      let(:original_results) { ['....', :passed] }
      it { expect(results).to eq(['....', :passed]) }
    end
  end

end
