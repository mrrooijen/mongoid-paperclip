# encoding: utf-8

begin
  require "paperclip"
rescue LoadError
  puts "Mongoid::Paperclip requires that you install the Paperclip gem."
  exit
end

##
# the id of mongoid is not integer, correct the id_partitioin.
Paperclip.interpolates :id_partition do |attachment, style|
  attachment.instance.id.to_s.scan(/.{4}/).join("/")
end

##
# mongoid criteria uses a different syntax.
module Paperclip
  module Helpers
    def each_instance_with_attachment(klass, name)
      class_for(klass).unscoped.where("#{name}_file_name".to_sym.ne => nil).each do |instance|
        yield(instance)
      end
    end
  end
end

##
# The Mongoid::Paperclip extension
# Makes Paperclip play nice with the Mongoid ODM
#
# Example:
#
#  class User
#    include Mongoid::Document
#    include Mongoid::Paperclip
#
#    has_mongoid_attached_file :avatar
#  end
#
# The above example is all you need to do. This will load the Paperclip library into the User model
# and add the "has_mongoid_attached_file" class method. Provide this method with the same values as you would
# when using "vanilla Paperclip". The first parameter is a symbol [:field] and the second parameter is a hash of options [options = {}].
#
# Unlike Paperclip for ActiveRecord, since MongoDB does not use "schema" or "migrations", Mongoid::Paperclip automatically adds the neccesary "fields"
# to your Model (MongoDB collection) when you invoke the "#has_mongoid_attached_file" method. When you invoke "has_mongoid_attached_file :avatar" it will
# automatially add the following fields:
#
#  field :avatar_file_name,    :type => String
#  field :avatar_content_type, :type => String
#  field :avatar_file_size,    :type => Integer
#  field :avatar_updated_at,   :type => DateTime
#  field :avatar_fingerprint,  :type => String
#
module Mongoid
  module Paperclip
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :localized_file_fields
      end

      @localized_file_fields = []
      field :localized_files,     type: Hash,   default: {}

      after_find do |that|
        that.localized_files.each do |field, locales|
          locales.each do |locale|
            define_mongoid_method(field, locale)
          end
        end
      end

      def method_missing(meth, *args, &block)
        setter = meth.to_s.last == '=' ? true : false
        arr = "#{meth}".gsub('=', '').split('_').map(&:to_sym)
        locale = arr.pop
        restored_method = (arr*('_')).to_sym
        if self.class.localized_file_fields.include?(restored_method)
          define_mongoid_method(restored_method, locale)
          self.send(meth, *args)
        else
          super
        end
      end


      def define_mongoid_method(field, locale, options={})
        self.class_eval do
          has_mongoid_attached_file("#{field}_#{locale}".to_sym)
          alias_method "#{field}_#{locale}_private=".to_sym, "#{field}_#{locale}=".to_sym
          alias_method "#{field}_#{locale}_private".to_sym, "#{field}_#{locale}".to_sym

          define_method("#{field}_#{locale}=") do |file|
            self.send("#{field}_#{locale}_private=".to_sym, file)
            presence = self.send("#{field}_#{locale}_private").present?
            update_localized_files_hash(field, locale, presence)
            file
          end

          define_method("#{field}_#{locale}") do
            self.send("#{field}_#{locale}_private".to_sym)
          end
        end
      end

      def update_localized_files_hash(field, locale, presence)
        locale = locale.to_sym
        self.localized_files["#{field}"] = [] if self.localized_files["#{field}"].blank?
        # adding a file
        if presence
          self.localized_files["#{field}"].push(locale) if !self.localized_files["#{field}"].include?(locale)
        # deleting a file
        elsif !presence
          self.localized_files["#{field}"].delete(locale) if self.localized_files["#{field}"].include?(locale)
        end
      end

    end

    ##
    # Extends the model with the defined Class methods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      ##
      # Adds after_commit
      def after_commit(*args, &block)
        options = args.pop if args.last.is_a? Hash
        if options
          case options[:on]
          when :create
            after_create(*args, &block)
          when :update
            after_update(*args, &block)
          when :destroy
            after_destroy(*args, &block)
          else
            after_save(*args, &block)
          end
        else
          after_save(*args, &block)
        end
      end

      ##
      # Adds Mongoid::Paperclip's "#has_mongoid_attached_file" class method to the model
      # which includes Paperclip and Paperclip::Glue in to the model. Additionally
      # it'll also add the required fields for Paperclip since MongoDB is schemaless and doesn't
      # have migrations.
      def has_mongoid_attached_file(field, options = {})
                  ##
          # Include Paperclip and Paperclip::Glue for compatibility
        unless self.ancestors.include?(::Paperclip)
          include ::Paperclip
          include ::Paperclip::Glue
        end
        if options.try(:[], :localize) == true
          localized_file_fields.push(field) if !localized_file_fields.include?(field)

          define_method(field) do |locale=I18n.locale|
            define_mongoid_method(field, locale, options)
            self.send("#{field}_#{locale}".to_sym)
          end

          define_method("#{field}=") do |file|
            locale = I18n.locale
            if file.is_a?(File) || file.nil?
              define_mongoid_method(field, locale, options)
              self.send("#{field}_#{locale}=".to_sym, file)
              presence = self.send("#{field}_#{locale}_private").present?
              update_localized_files_hash(field, locale, presence)
              file
            else
              raise new TypeError("wrong argument type #{file.class} (expected File)")
            end
          end

          define_method("#{field}_translations=") do |hashed_files|
            hashed_files.each do |locale, file|
              if (locale.is_a?(Symbol) || locale.is_a?(String)) && (file.is_a?(File) || file.nil?)
                define_mongoid_method(field, locale, options)
                self.send("#{field}_#{locale}=".to_sym, file)
                presence = self.send("#{field}_#{locale}_private").present?
                update_localized_files_hash(field, locale, presence)
                file
              elsif file.is_a?(File) || file.nil?
                raise new TypeError("wrong argument type #{locale.klass} (expected Symbol or String)")
              elsif locale.is_a?(Symbol) || locale.is_a?(String)
                raise new TypeError("wrong argument type #{file.klass} (expected File)")
              end
              self.localized_files
            end
          end

          define_method("#{field}_translations") do
            self.localized_files["#{field}"]
          end
        else

          ##
          # Invoke Paperclip's #has_attached_file method and passes in the
          # arguments specified by the user that invoked Mongoid::Paperclip#has_mongoid_attached_file
          options.delete(:localize)
          has_attached_file(field, options)

          ##
          # Define the necessary collection fields in Mongoid for Paperclip
          field(:"#{field}_file_name",    :type => String)
          field(:"#{field}_content_type", :type => String)
          field(:"#{field}_file_size",    :type => Integer)
          field(:"#{field}_updated_at",   :type => DateTime)
          field(:"#{field}_fingerprint",  :type => String)
        end
      end

      ##
      # This method is deprecated
      def has_attached_file(field, options = {})
        raise "Mongoid::Paperclip#has_attached_file is deprecated, " +
              "Use 'has_mongoid_attached_file' instead"
      end
    end

  end
end
