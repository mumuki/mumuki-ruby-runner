_true = true

describe '_true' do
  it 'is true' do
    expect(_true).to be true
  end

  it 'is not _false' do
    expect(_true).to_not be false
  end

  it 'is is something that will fail' do
    expect(_true).to be 3
  end
end
