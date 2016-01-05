class MetadataPublisher < Mumukit::Hook
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
         test_extension: '.rb'
     }}
  end
end