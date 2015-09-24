require_relative './spec_helper'
require 'ostruct'

describe QueryRunner do
  let(:query_runner) { QueryRunner.new(nil) }
  let(:request) {OpenStruct.new(query: '5')}

  it { expect(query_runner.run_query!(request)[0]).to eq '=> 5' }

end
