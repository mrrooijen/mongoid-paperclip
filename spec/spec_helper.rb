require 'rspec'
require 'mongoid'
require 'mongoid-paperclip'

ENV['MONGOID_ENV'] = 'test'
Mongoid.load!('./spec/config/mongoid.yml')

RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
  end
end

class User
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
  validates_attachment_file_name :avatar, matches: [/image/]
end

class MultipleAttachments
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
  validates_attachment_file_name :avatar, matches: [/image/]

  has_mongoid_attached_file :icon
  validates_attachment_file_name :avatar, matches: [/image/]
end
