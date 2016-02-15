require_relative './spec_helper'


class File
  def unlink
  end
end


describe 'running' do
  let(:runner) { TestHook.new('rspec_command' => 'rspec') }
  let(:file) { File.new('spec/data/sample.rb') }
  let(:file_multi) { File.new('spec/data/sample_multi.rb') }
  let(:file_failed) { File.new('spec/data/sample_failed.rb') }

  describe '#run_test_command' do
    it { expect(runner.command_line(file.path)).to include('rspec spec/data/sample.rb') }
  end

  describe '#run!' do
    context 'on simple passed file' do
      let(:results) { runner.run!(file) }

      it { expect(results[0]).to eq([['_true is true', :passed, '']]) }
    end

    context 'on simple failed file' do
      let(:results) { runner.run!(file_failed) }

      it { expect(results[0]).to(
          eq([['_true is is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end

    context 'on multi file' do
      let(:results) { runner.run!(file_multi) }

      it { expect(results[0]).to(
          eq([['_true is true', :passed, ''],
              ['_true is not _false', :passed, ''],
              ['_true is is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end
  end
end
