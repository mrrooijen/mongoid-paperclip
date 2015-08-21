# encoding: utf-8

Gem::Specification.new do |gem|

  gem.name        = 'mongoid-paperclip'
  gem.version     = '0.0.10'
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = 'Michael van Rooijen'
  gem.email       = 'michael@vanrooijen.io'
  gem.homepage    = 'https://github.com/meskyanichi/mongoid-paperclip'
  gem.summary     = 'Paperclip compatibility for Mongoid ODM for MongoDB.'
  gem.description = 'Enables you to use Paperclip with the Mongoid ODM for MongoDB.'
  gem.license     = 'MIT'

  gem.files         = %x[git ls-files].split("\n")
  gem.test_files    = %x[git ls-files -- {spec}/*].split("\n")
  gem.require_path  = 'lib'

  gem.add_dependency 'paperclip', ['>= 2.3.6', '!=4.3.0']
end
