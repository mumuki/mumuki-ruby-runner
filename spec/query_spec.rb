require_relative './spec_helper'
require 'ostruct'

describe RubyQueryHook do
  let(:hook) { RubyQueryHook.new(nil) }
  let(:file) { hook.compile(request) }
  let(:result) {
    hook.run!(file)
  }


  context 'just query' do
    let(:request) { struct(query: '5') }
    it { expect(result[0]).to eq "=> 5\n" }
  end

  context 'query with one line error output' do
    let(:request) { struct(query: 'true.unknown_message') }
    it { expect(result[0]).to eq "undefined method `unknown_message' for true:TrueClass (NoMethodError)" }
    it { expect(result[1]).to eq :failed }
  end

  context 'query with multiline error output' do
    let(:request) { struct(query: 'true.inspect("invalid argument")') }
    it { expect(result[0]).to eq 'wrong number of arguments (1 for 0) (ArgumentError)' }
    it { expect(result[1]).to eq :failed }
  end

  context 'query and content' do
    let(:request) { struct(query: 'x', content: 'x=2*2') }
    it { expect(result[0]).to eq "=> 4\n" }
  end

  context 'query and extra' do
    let(:request) { struct(query: 'y', extra: 'y=64+2') }
    it { expect(result[0]).to eq "=> 66\n" }
  end

  context 'query and cookie' do
    let(:request) { struct(query: 'y + 1', cookie: ['y=64']) }
    it { expect(result[0]).to eq "=> 65\n" }
  end
  context 'query and failed cookie' do
    let(:request) { struct(query: 'y', cookie: ['y=5', 'raise a']) }
    it { expect(result[0]).to eq "=> 5\n" }
  end
  context 'query and puts in cookie' do
    let(:request) { struct(query: 'y', cookie: ['y=5', 'puts 999999']) }
    it { expect(result[0]).to eq "=> 5\n" }
  end
  context 'query and puts in query' do
    let(:request) { struct(query: 'puts y', cookie: ['y=5', 'puts 999999']) }
    it { expect(result[0]).to eq "5\n=> nil\n" }
  end
  context 'query and function in cookie' do
    let(:request) { struct(query: 'x', cookie: ['def x; 5; end']) }
    it { expect(result[0]).to eq "=> 5\n" }
  end
  context 'query and function in query' do
    let(:request) { struct(query: 'def x;5;end', cookie: []) }
    it { expect(result[0]).to eq "=> nil\n" }
  end

end
