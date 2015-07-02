require_relative './spec_helper'

describe TestRunner do
  let(:runner) { TestRunner.new('rspec_command' => 'rspec') }
  let(:file) { File.new('spec/data/sample.rb') }
  let(:file_multi) { File.new('spec/data/sample_multi.rb') }
  let(:file_failed) { File.new('spec/data/sample_failed.rb') }

  describe '#run_test_command' do
    it { expect(runner.run_test_command(file)).to include('rspec spec/data/sample_spec.rb') }
    it { expect(runner.run_test_command(file)).to include('2>&1') }
  end

  describe '#run_test_file!' do
    context 'on simple passed file' do
      let(:results) { runner.run_test_file!(file) }

      it { expect(results[0]).to eq([{title: '_true is true', exit: :passed, out: ''}]) }
      it { expect(results[1]).to eq(:passed) }
    end

    context 'on simple failed file' do
      let(:results) { runner.run_test_file!(file_failed) }

      it { expect(results[0]).to eq([{title: '_true is is something that will fail', exit: :failed, out: ''}]) }
      it { expect(results[1]).to eq(:failed) }
    end

    context 'on multi file' do
      let(:results) { runner.run_test_file!(file_multi) }

      it { expect(results[0]).to eq([{title: '_true is true', exit: :passed, out: ''},
                                     {title: '_true is not _false', exit: :passed, out: ''},
                                     {title: '_true is is something that will fail', exit: :failed, out: 'dasdas'}]) }
      it { expect(results[1]).to eq(:failed) }
    end
  end
end
