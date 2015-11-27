require_relative '../spec/spec_helper' #FIXME remove. There must be an issue with mumukit-bridge requires

require 'mumukit/bridge'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Bridge.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'prevents malicious net related code' do
    response = bridge.run_tests!(test: 'describe "foo" do  it { expect(x).to eq 3 } end',
                                 extra: '',
                                 content: 'require "net/http"; Net::HTTP.get("http://www.google.com")',
                                 expectations: [])
    expect(response[:status]).to eq(:errored)
    expect(response[:result]).to include("undefined method `hostname'")
  end


  pending 'prevents malicious allocation related code' do
    response = bridge.run_tests!(test: 'describe "foo" do  it { expect(x).to eq 3 } end',
                                 extra: '',
                                 expectations: [],
                                 content: <<-EOF

  l = (1..1024*1024*10).map { Object.new }
  l.size

    EOF
    )
    expect(response).to eq(:errored)
  end


  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: 'describe "foo" do  it("bar") { expect(x).to eq 3 } end',
                                 extra: '',
                                 content: 'x = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission is not ok' do
    response = bridge.
        run_tests!(test: 'describe("foo") do  it("bar"){ expect(x).to eq 3 } end',
                   extra: '',
                   content: 'x = 2',
                   expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [
                               {title: 'foo bar', status: :failed, result: "\nexpected: 3\n     got: 2\n\n(compared using ==)\n"}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission timeouts' do
    response = bridge.
        run_tests!(test: 'describe("foo") do  it("bar"){ sleep(300) ; expect(x).to eq 3 } end',
                   extra: '',
                   content: 'x = 2',
                   expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :aborted,
                           feedback: '',
                           expectation_results: [],
                           result: 'Execution time limit of 4s exceeded. Is your program performing an infinite loop or recursion?')
  end


  it 'answers a valid hash when submission has compilation errors' do
    response = bridge.
        run_tests!(test: 'describe("foo") do  it("bar"){ expect(x).to eq 3 } end',
                   extra: '',
                   content: 'x = ).',
                   expectations: [])

    expect(response[:status]).to eq :errored
    expect(response[:response_type]).to eq(:unstructured)
    expect(response[:test_results]).to be_empty
    expect(response[:result]).to include("syntax error, unexpected ')' (SyntaxError)\nx = ).")

  end

end
