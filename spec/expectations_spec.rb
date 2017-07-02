require_relative 'spec_helper'

describe RubyExpectationsHook do
  def req(expectations, content)
    struct expectations: expectations, content: content
  end

  def compile_and_run(request)
    runner.run!(runner.compile(request))
  end

  let(:runner) { RubyExpectationsHook.new(mulang_path: './bin/mulang') }
  let(:result) { compile_and_run(req(expectations, code)) }

  context 'smells' do
    let(:code) { 'x = 4' }
    let(:expectations) { [] }

    it { expect(result).to eq [{binding: 'x', inspection: 'HasTooShortBindings'}] }
  end


  context 'expectations' do
    let(:code) { 'pepita = Object.new' }
    let(:declares_foo) { {binding: '', inspection: 'DeclaresVariable:foo'} }
    let(:declares_pepita) { {binding: '', inspection: 'DeclaresVariable:pepita'} }
    let(:expectations) { [declares_foo, declares_pepita] }

    it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
  end

end
