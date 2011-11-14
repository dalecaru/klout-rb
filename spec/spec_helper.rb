require 'klout'
require 'rspec'
require "webmock/rspec"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include WebMock::API
  config.mock_with :rspec
end

def stub_get(path)
  stub_request(:get, Klout::Client.endpoint + path)
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
