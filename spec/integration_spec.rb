require 'mumukit/bridge'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Bridge.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }


  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: 'describe "foo" do  it { expect(x).to eq 3 } end',
                                 extra: '',
                                 content: 'x = 3',
                                 expectations: [])

    expect(response[:result]).to include('1 example, 0 failures')
    expect(response[:status]).to eq 'passed'
  end

  it 'answers a valid hash when submission is not ok' do
    response = bridge.
        run_tests!(test: 'describe "foo" do  it { expect(x).to eq 3 } end',
                   extra: '',
                   content: 'x = 2).',
                   expectations: [])

    expect(response[:status]).to eq 'failed'
  end


end