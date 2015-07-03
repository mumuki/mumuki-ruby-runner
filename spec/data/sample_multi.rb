_true = true

describe '_true' do
  it 'is true' do
    expect(_true).to eq true
  end

  it 'is not _false' do
    expect(_true).to_not eq false
  end

  it 'is is something that will fail' do
    expect(_true).to eq 3
  end
end
