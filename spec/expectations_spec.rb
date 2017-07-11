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

    describe 'UsesLambda' do
      let(:code) { '[4].map {|it| it + 1}' }
      let(:uses_lambda) { {binding: '', inspection: 'UsesLambda'} }
      let(:expectations) { [uses_lambda] }

      it { expect(result).to eq [{expectation: uses_lambda, result: true}] }
    end

    describe 'Uses' do
      let(:code) { '
        class Foo; def m; end; end;
        class Bar; def m; self.g; end; end' }
      let(:foo_delegates) { {binding: 'Foo', inspection: 'Uses:*'} }
      let(:foo_m_delegates) { {binding: 'Intransitive:Foo.m', inspection: 'Uses:*'} }
      let(:bar_m_delegates) { {binding: 'Intransitive:Bar.m', inspection: 'Uses:*'} }
      let(:expectations) { [foo_delegates, foo_m_delegates, bar_m_delegates, {binding: '', inspection: 'Except:HasTooShortBindings'}] }

      it { expect(result).to eq [{expectation: foo_delegates, result: false},
                                 {expectation: foo_m_delegates, result: false},
                                 {expectation: bar_m_delegates, result: true}] }
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
