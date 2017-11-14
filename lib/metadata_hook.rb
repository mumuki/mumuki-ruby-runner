class RubyMetadataHook < Mumukit::Hook
  def metadata
    {language: {
        name: 'ruby',
        icon: {type: 'devicon', name: 'ruby'},
        version: '2.0',
        extension: 'rb',
        ace_mode: 'ruby'
    },
     test_framework: {
         name: 'rspec',
         version: '2.13',
         test_extension: 'rb',
         template: <<ruby
describe '{{ test_template_group_description }}' do
  it '{{ test_template_sample_description }}' do
    expect(true).to eq true
  end
end
ruby
     }}
  end
end