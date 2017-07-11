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
    let(:code) { 'module X; end' }
    let(:expectations) { [] }

    it { expect(result).to eq [{binding: 'X', inspection: 'HasTooShortBindings'}] }
  end


  context 'expectations' do
    describe 'declaresObject' do
      let(:code) { 'module Pepita; end' }
      let(:declares_foo) { {binding: '', inspection: 'DeclaresObject:Foo'} }
      let(:declares_pepita) { {binding: '', inspection: 'DeclaresObject:Pepita'} }
      let(:expectations) { [declares_foo, declares_pepita] }

      it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
    end

    describe 'assigns' do
      let(:code) { 'pepita = Object.new' }
      let(:assigns_foo) { {binding: '', inspection: 'Assigns:foo'} }
      let(:assigns_pepita) { {binding: '', inspection: 'Assigns:pepita'} }
      let(:expectations) { [assigns_foo, assigns_pepita] }

      it { expect(result).to eq [{expectation: assigns_foo, result: false}, {expectation: assigns_pepita, result: true}] }
    end
  end

end
