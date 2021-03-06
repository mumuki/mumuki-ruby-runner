require_relative 'spec_helper'

describe RubyExpectationsHook do
  def req(expectations, content)
    struct expectations: expectations, content: content
  end

  def compile_and_run(request)
    runner.run!(runner.compile(request))
  end

  let(:runner) { RubyExpectationsHook.new }
  let(:result) { compile_and_run(req(expectations, code)) }

  describe 'smells' do
    context 'with wrong case identifiers' do
      let(:code) { <<-RUBY
        module  Foo_Bar
          def fooBar
          end
          def y
          end
          def aB
          end
        end
        module  Foo
        end
      RUBY
     }

      let(:expectations) { [] }

      it { expect(result).to include expectation: {binding: 'Foo_Bar', inspection: 'HasWrongCaseIdentifiers'}, result: false }
      it { expect(result).to_not include expectation: {binding: 'Foo_Bar', inspection: 'HasTooShortIdentifiers'}, result: false }

      it { expect(result).to include expectation: {binding: 'fooBar', inspection: 'HasWrongCaseIdentifiers'}, result: false }
      it { expect(result).to_not include expectation: {binding: 'fooBar', inspection: 'HasTooShortIdentifiers'}, result: false }

      it { expect(result).to_not include expectation: {binding: 'y', inspection: 'HasWrongCaseIdentifiers'}, result: false }
      it { expect(result).to include expectation: {binding: 'y', inspection: 'HasTooShortIdentifiers'}, result: false }

      it { expect(result).to include expectation: {binding: 'aB', inspection: 'HasWrongCaseIdentifiers'}, result: false }
      it { expect(result).to include expectation: {binding: 'aB', inspection: 'HasTooShortIdentifiers'}, result: false }

      it { expect(result).to_not include expectation: {binding: 'Foo', inspection: 'HasWrongCaseIdentifiers'}, result: false }
      it { expect(result).to_not include expectation: {binding: 'Foo', inspection: 'HasTooShortIdentifiers'}, result: false }

      it { expect(result.size).to eq 5 }
    end

    describe 'if smells' do
      let(:expectations) { [] }

      describe 'HasEmptyIfBranches' do
        let(:code) do
          %q{
            module FooBar
              def self.do_foo
                if some_condition
                end
              end
            end
          }
        end

        it { expect(result).to include expectation: {binding: "do_foo", inspection: "HasEmptyIfBranches"}, result: false }
      end

      describe 'HasEqualIfBranches' do
        let(:code) do
          %q{
            module FooBar
              def self.do_foo
                if some_condition
                  do_it!
                else
                  do_it!
                end
              end
            end
          }
        end

        it { expect(result).to include expectation: {binding: "do_foo", inspection: "HasEqualIfBranches"}, result: false }
      end


      describe 'HasRedundantIf' do
        let(:code) do
          %q{
            module FooBar
              def self.do_foo
                if some_condition
                  true
                else
                  false
                end
              end
            end
          }
        end

        it { expect(result).to include expectation: {binding: "do_foo", inspection: "HasRedundantIf"}, result: false }
      end


      describe 'ShouldInvertIfCondition' do
        let(:code) do
          %q{
            module FooBar
              def self.do_foo
                if some_condition
                else
                  do_it!
                end
              end
            end
          }
        end

        it { expect(result).to include expectation: {binding: "do_foo", inspection: "ShouldInvertIfCondition"}, result: false }
      end

    end

    context 'no domain language smells' do
      let(:code) { 'module FooBar; def foo_bar; end; end' }
      let(:expectations) { [] }

      it { expect(result).to eq [] }
    end
  end

  context 'expectations' do
    describe 'DeclaresObject' do
      let(:code) { 'module Pepita; end' }
      let(:declares_foo) { {binding: '*', inspection: 'DeclaresObject:Foo'} }
      let(:declares_pepita) { {binding: '*', inspection: 'DeclaresObject:Pepita'} }
      let(:expectations) { [declares_foo, declares_pepita] }

      it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
    end

    describe 'DeclaresClass' do
      let(:code) { 'class Pepita; end' }
      let(:declares_foo) { {binding: '*', inspection: 'DeclaresClass:Foo'} }
      let(:declares_pepita) { {binding: '*', inspection: 'DeclaresClass:Pepita'} }
      let(:expectations) { [declares_foo, declares_pepita] }

      it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
    end

    describe 'UsesMath' do
      let(:uses_math) { {binding: '*', inspection: 'UsesMath'} }
      let(:uses_minus) { {binding: '*', inspection: 'Uses:-'} }
      let(:uses_minus_operator) { {binding: '*', inspection: 'UsesMinus'} }
      let(:returns_with_math) { {binding: '*', inspection: 'Returns:WithMath'} }

      context 'when used in assignment' do
        let(:code) { 'class Pepita; def fly!; @energy = energy - 10 end end' }
        let(:expectations) { [uses_math, uses_minus, returns_with_math] }

        it do
          expect(result).to eq [
              {expectation: uses_math, result: true},
              {expectation: uses_minus_operator, result: true},
              {expectation: returns_with_math, result: false} ]
        end
      end

      context 'when used in implicit return' do
        let(:code) { 'class Pepita; def required_energy; @energy - 50 end end' }
        let(:expectations) { [uses_math, uses_minus, returns_with_math] }

        it do
          expect(result).to eq [
              {expectation: uses_math, result: true},
              {expectation: uses_minus_operator, result: true},
              {expectation: returns_with_math, result: true} ]
        end
      end

      context 'when used in explicit return' do
        let(:code) { 'class Pepita; def required_energy; return @energy - 50 end end' }
        let(:expectations) { [uses_math, uses_minus, returns_with_math] }

        it do
          expect(result).to eq [
              {expectation: uses_math, result: true},
              {expectation: uses_minus_operator, result: true},
              {expectation: returns_with_math, result: true} ]
        end
      end
    end

    describe 'UsesSize' do
      let(:uses_size) { {binding: '*', inspection: 'Uses:size'} }
      let(:uses_length) { {binding: '*', inspection: 'Uses:length'} }
      let(:uses_size_operator) { {binding: '*', inspection: 'UsesSize'} }
      let(:expectations) { [uses_size, uses_length, uses_size] }

      context 'when uses size' do
        let(:code) { '[].size' }

        it do
          expect(result).to eq [
            {expectation: uses_size_operator, result: true},
            {expectation: uses_size_operator, result: true},
            {expectation: uses_size_operator, result: true}
          ]
        end
      end

      context 'when uses length' do
        let(:code) { '[].length' }

        it do
          expect(result).to eq [
            {expectation: uses_size_operator, result: true},
            {expectation: uses_size_operator, result: true},
            {expectation: uses_size_operator, result: true}
          ]
        end
      end

      context 'when neither length nor size is used' do
        let(:code) { '[].compact' }

        it do
          expect(result).to eq [
            {expectation: uses_size_operator, result: false},
            {expectation: uses_size_operator, result: false},
            {expectation: uses_size_operator, result: false}
          ]
        end
      end
    end


    describe 'UsesInheritance' do
      context 'when uses' do
        let(:code) { 'class Pepita < Bird; end' }
        let(:uses_inheritance) { {binding: 'Pepita', inspection: 'UsesInheritance'} }
        let(:expectations) { [uses_inheritance] }

        it { expect(result).to eq [{expectation: uses_inheritance, result: true}] }
      end
      context 'when not uses' do
        let(:code) { 'class Pepita; end' }
        let(:uses_inheritance) { {binding: 'Pepita', inspection: 'UsesInheritance'} }
        let(:expectations) { [uses_inheritance] }

        it { expect(result).to eq [{expectation: uses_inheritance, result: false}] }
      end
    end

    describe 'DeclaresMethod' do
      let(:code) { 'class Pepita; def canta; end; end' }
      let(:declares_methods) { {binding: '*', inspection: 'DeclaresMethod'} }
      let(:declares_canta) { {binding: '*', inspection: 'DeclaresMethod:canta'} }
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
      let(:uses_lambda) { {binding: '*', inspection: 'UsesLambda'} }
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
      let(:expectations) { [foo_delegates, foo_m_delegates, bar_m_delegates, {binding: '*', inspection: 'Except:HasTooShortIdentifiers'}] }

      it { expect(result).to eq [{expectation: foo_delegates, result: false},
                                 {expectation: foo_m_delegates, result: false},
                                 {expectation: bar_m_delegates, result: true}] }
    end

    describe 'Assigns' do
      let(:code) { 'pepita = Object.new' }
      let(:assigns_foo) { {binding: '*', inspection: 'Assigns:foo'} }
      let(:assigns_pepita) { {binding: '*', inspection: 'Assigns:pepita'} }
      let(:expectations) { [assigns_foo, assigns_pepita] }

      it { expect(result).to eq [{expectation: assigns_foo, result: false}, {expectation: assigns_pepita, result: true}] }
    end
  end

end
