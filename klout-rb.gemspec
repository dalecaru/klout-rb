# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "klout/version"

Gem::Specification.new do |s|
  s.name        = "klout-rb"
  s.version     = Klout::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Damian Caruso"]
  s.email       = ["damian.caruso@gmail.com"]
  s.homepage    = "http://github.com/cdamian/klout-rb"
  s.summary     = %q{Ruby wrapper for the Klout REST API}
  s.description = %q{Ruby wrapper for the Klout REST API}

  s.rubyforge_project = "klout-rb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "hashie", "~> 1.2.0"
  s.add_dependency "httpi", "~> 0.9.5"
  s.add_dependency "multi_json", "~> 1.3"
  
  s.add_development_dependency "rake", "~> 0.9.2.2"
  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "webmock", "~> 1.7.7"
end

