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

    it { expect(result).to eq [{expectation: {binding: 'X', inspection: 'HasTooShortBindings'}, result: false}] }
  end

  context 'expectations' do
    describe 'DeclaresObject' do
      let(:code) { 'module Pepita; end' }
      let(:declares_foo) { {binding: '', inspection: 'DeclaresObject:Foo'} }
      let(:declares_pepita) { {binding: '', inspection: 'DeclaresObject:Pepita'} }
      let(:expectations) { [declares_foo, declares_pepita] }

      it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
    end

    describe 'DeclaresClass' do
      let(:code) { 'class Pepita; end' }
      let(:declares_foo) { {binding: '', inspection: 'DeclaresClass:Foo'} }
      let(:declares_pepita) { {binding: '', inspection: 'DeclaresClass:Pepita'} }
      let(:expectations) { [declares_foo, declares_pepita] }

      it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
    end

    describe 'DeclaresMethod' do
      let(:code) { 'class Pepita; def canta; end; end' }
      let(:declares_methods) { {binding: '', inspection: 'DeclaresMethod'} }
      let(:declares_canta) { {binding: '', inspection: 'DeclaresMethod:canta'} }
      let(:pepita_declares_canta) { {binding: 'Pepita', inspection: 'DeclaresMethod:canta'} }
      let(:pepita_declares_vola) { {binding: 'Pepita', inspection: 'DeclaresMethod:vola'} }
      let(:expectations) { [declares_methods, declares_canta, pepita_declares_canta, pepita_declares_vola] }

      it { expect(result).to eq [
          {expectation: declares_methods, result: true},
          {expectation: declares_canta, result: true},
          {expectation: pepita_declares_canta, result: true},
          {expectation: pepita_declares_vola, result: false}] }
    end

    describe 'Assigns' do
      let(:code) { 'pepita = Object.new' }
      let(:assigns_foo) { {binding: '', inspection: 'Assigns:foo'} }
      let(:assigns_pepita) { {binding: '', inspection: 'Assigns:pepita'} }
      let(:expectations) { [assigns_foo, assigns_pepita] }

      it { expect(result).to eq [{expectation: assigns_foo, result: false}, {expectation: assigns_pepita, result: true}] }
    end
  end

end
