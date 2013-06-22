describe Sword do
  it 'prints the version' do
    `./bin/sword -v`.should == "Sword #{Sword::VERSION}\n"
  end

  # @todo fix the platform-specific solution
  it 'prints help information' do
    `./bin/sword -h`['Usage: sword [options]']
  end
end
