require_relative './spec_helper'
require 'ostruct'

describe RubyQueryHook do
  let(:hook) { RubyQueryHook.new(nil) }
  let(:file) { hook.compile(request) }
  let(:result) {
    hook.run!(file)
  }


  context 'just query' do
    let(:request) { OpenStruct.new(query: '5') }
    it { expect(result[0]).to eq "=> 5\n" }
  end

  context 'query and content' do
    let(:request) { OpenStruct.new(query: 'x', content: 'x=2*2') }
    it { expect(result[0]).to eq "=> 4\n" }
  end

  context 'query and extra' do
    let(:request) { OpenStruct.new(query: 'y', extra: 'y=64+2') }
    it { expect(result[0]).to eq "=> 66\n" }
  end
end
