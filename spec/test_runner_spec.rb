require_relative './spec_helper'

describe TestRunner do
  let(:runner) { TestRunner.new('rspec_command' => 'rspec') }
  let(:file) { File.new('spec/data/sample_spec.rb') }

  describe '#run_test_command' do
    it { expect(runner.run_test_command(file)).to include('rspec spec/data/sample_spec.rb') }
    it { expect(runner.run_test_command(file)).to include('2>&1') }
  end

  describe '#validate_compile_errors' do
    let(:results) { runner.run_test_file!(file) }

    describe 'fails on test errors' do
      it { expect(results[0]).to include '1 example'}
      it { expect(results[1]).to eq(:passed) }
    end
  end
end
