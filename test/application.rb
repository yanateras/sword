describe Sword::Application do
  Dir.chdir './example'
  include Rack::Test::Methods
  
  def app
    Sword::Application
  end

  it 'should get / and synonymize it to /index' do
    get '/'
    last_request.should == File.read('index.html')
  end

  it 'should synonymize /foo to /foo/index if /foo is not found' do
    get '/synonym'
    last_request.should == File.read('synonym/index.html')
  end

  it 'should prefer page over /index synonym' do
    get '/no_synonym'
    last_request.should == File.read('no_synonym.html')
  end

  it 'should prefer pure HTML over templates' do
    get '/favourite/page'
    last_request.should == File.read('favourite/page.html')
  end

  it 'should prefer pure CSS over preprocessors' do
    get '/favourite/style'
    last_request.should == File.read('favourite/style.css')
  end

  it 'should prefer pure JS over CoffeeScript' do
    get '/favourite/script'
    last_request.should == File.read('favourite/script.js')
  end
end
