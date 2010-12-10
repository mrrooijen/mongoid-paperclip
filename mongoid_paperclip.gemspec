# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/lib/mongoid_paperclip')

Gem::Specification.new do |gem|

  gem.name        = 'mongoid-paperclip'
  gem.version     = Mongoid::Paperclip::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = 'Michael van Rooijen'
  gem.email       = 'meskyanichi@gmail.com'
  gem.homepage    = 'https://github.com/meskyanichi/mongoid-paperclip'
  gem.summary     = 'Mongoid::Paperclip enables you to use Paperclip (File Attachment) with the Mongoid ORM for MongoDB.'
  gem.description = 'Mongoid::Paperclip is a simple gem that allows you to (even easier than ActiveRecord) use the popular file uploader "Paperclip" with the Mongoid ORM for MongoDB.'

  gem.files         = %x[git ls-files].split("\n")
  gem.test_files    = %x[git ls-files -- {spec}/*].split("\n")
  gem.require_path  = 'lib'
  
  gem.add_dependency 'paperclip', ['~> 2.3.6']

end