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
end
