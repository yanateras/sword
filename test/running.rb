describe 'running and loading' do
  it 'prints the version' do
    assert_equal `bin/sword -v`, "Sword #{Sword::VERSION}\n"
  end
  it 'prints help information' do
    assert `bin/sword -h`['Usage: sword [options]']
  end
  it 'gets index.html' do
    `bin/sword -d example`
    assert_equal `curl localhost:1111`, File.read('example/index.html')
  end
end
