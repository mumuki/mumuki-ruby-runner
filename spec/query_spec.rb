require_relative './spec_helper'
require 'ostruct'

describe QueryRunner do
  let(:query_runner) { QueryRunner.new(nil) }
  let(:request) {OpenStruct.new(query: '5')}
  let(:request_content) {OpenStruct.new(query:'x' , content: 'x=2*2')}
  let(:request_extra) {OpenStruct.new(query:'y', content:'y=64+2' )}


  it { expect(query_runner.run_query!(request)[0]).to eq '=> 5' }
  it { expect(query_runner.run_query!(request_content)[0]).to eq '=> 4' }
  it { expect(query_runner.run_query!(request_extra)[0]).to eq '=> 66' }

end
