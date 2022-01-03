# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name        = 'mongoid-paperclip'
  gem.version     = '1.0.0.pre'
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ['Michael van Rooijen', 'Joost Baaij']
  gem.email       = ['michael@vanrooijen.io', 'joost@spacebabies.nl']
  gem.homepage    = 'https://github.com/mrrooijen/mongoid-paperclip'
  gem.summary     = 'Paperclip compatibility for Mongoid ODM for MongoDB.'
  gem.description = 'Enables you to use Paperclip with the Mongoid ODM for MongoDB.'
  gem.license     = 'MIT'

  gem.files         = %x[git ls-files].split("\n")
  gem.test_files    = %x[git ls-files -- {spec}/*].split("\n")
  gem.require_path  = 'lib'

  gem.add_dependency 'mongoid'
  gem.add_dependency 'kt-paperclip'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
