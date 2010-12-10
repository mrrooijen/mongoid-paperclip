##
# The logger is set to the Active Record logger by Paperclip itself.
# Because of this, we set the logger to false as "default" so that it doesn't raise
# an "uninitialized constant" exception.
#
# You can manually change loggers by adding for example an initializer and configuring the logger, like so:
#
#   Paperclip.options[:log] = MyLogger.log
#
Paperclip.options[:log] = false

##
# If Ruby on Rails is defined and the logger method exists, the Paperclip logger
# will be set to the Rails logger by default. You may overwrite the logger by re-defining the
# logger in for example an initializer file, like so:
#
#  Paperclip.options[:log] = MyLogger.log
#
if defined?(Rails)
  if Rails.respond_to?(:logger)
    Paperclip.options[:log] = Rails.logger
  end
end

##
# The Mongoid::Paperclip extension
# Makes Paperclip play nice with the Mongoid ORM
#
# Example:
#
#  class User
#    include Mongoid::Document
#    include Mongoid::Paperclip
#
#    has_attached_file :avatar
#  end
#
# The above example is all you need to do. This will load the Paperclip library into the User model
# and add the "has_attached_file" class method. Provide this method with the same values as you would
# when using "vanilla Paperclip". The first parameter is a symbol [:field] and the second parameter is a hash of options [options = {}].
#
# Unlike Paperclip for ActiveRecord, since MongoDB does not use "schema" or "migrations", Mongoid::Paperclip automatically adds the neccesary "fields"
# to your Model (MongoDB collection) when you invoke the "#has_attached_file" method. When you invoke "has_attached_file :avatar" it will
# automatially add the following fields:
#
#  field :avatar_file_name,    :type => String
#  field :avatar_content_type, :type => String
#  field :avatar_file_size,    :type => Integer
#  field :avatar_updated_at,   :type => DateTime
#
module Mongoid
  module Paperclip

    ##
    # Extends the model with the defined Class methods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      ##
      # Adds Mongoid::Paperclip's "#has_attached_file" class method to the model
      # which includes Paperclip and Paperclip::Glue in to the model. Additionally
      # it'll also add the required fields for Paperclip since MongoDB is schemaless and doesn't
      # have migrations.
      def has_attached_file(field, options = {})
        include ::Paperclip
        include ::Paperclip::Glue
        has_attached_file(field, options)
        field(:"#{field}_file_name",    :type => String)
        field(:"#{field}_content_type", :type => String)
        field(:"#{field}_file_size",    :type => Integer)
        field(:"#{field}_updated_at",   :type => DateTime)
      end
    end

  end
end