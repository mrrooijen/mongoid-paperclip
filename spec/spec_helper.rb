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

# Mock Rails itself so Paperclip can write the attachments to a directory.
class Rails
  def self.root
    File.expand_path(File.dirname(__FILE__))
  end
end

class User
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
end

class MultipleAttachments
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  has_mongoid_attached_file :icon
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\Z/
end

class NoFingerprint
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar, disable_fingerprint: true
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
end
