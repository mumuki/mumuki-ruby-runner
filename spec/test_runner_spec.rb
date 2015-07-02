require_relative './spec_helper'


class File
  def unlink
  end
end


describe TestRunner do
  let(:runner) { TestRunner.new('rspec_command' => 'rspec') }
  let(:file) { File.new('spec/data/sample.rb') }
  let(:file_multi) { File.new('spec/data/sample_multi.rb') }
  let(:file_failed) { File.new('spec/data/sample_failed.rb') }

  describe '#run_test_command' do
    it { expect(runner.run_test_command(file)).to include('rspec spec/data/sample.rb') }
    it { expect(runner.run_test_command(file)).to include('2>&1') }
  end

  describe '#run_compilation!' do
    context 'on simple passed file' do
      let(:results) { runner.run_compilation!(file) }

      it { expect(results[0]).to eq([['_true is true', :passed, '']]) }
    end

    context 'on simple failed file' do
      let(:results) { runner.run_compilation!(file_failed) }

      it { expect(results[0]).to(
          eq([['_true is is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end

    context 'on multi file' do
      let(:results) { runner.run_compilation!(file_multi) }

      it { expect(results[0]).to(
          eq([['_true is true', :passed, ''],
              ['_true is not _false', :passed, ''],
              ['_true is is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end
  end
end
