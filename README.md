Mongoid::Paperclip - Making Paperclip play nice with Mongoid ODM
================================================================

As the title suggests, using this gem you will be able to use [Paperclip](https://github.com/thoughtbot/paperclip) with [Mongoid](http://mongoid.org/).

This is actually **easier** and **faster** to set up than when using the ActiveRecord ORM.

This example assumes you are using **Ruby on Rails 3** and **Bundler**. However it doesn't require either.


Setting it up in a few seconds
------------------------------

First require the **Paperclip** gem as you normally would, followed by the **Mongoid::Paperclip** extension. Additionally if you are working with Amazon S3 you will want to add the AWS::S3 gem to your Gemfile as well.

**Rails.root/Gemfile**

    gem "paperclip"
    gem "mongoid-paperclip", :require => "mongoid_paperclip"
    gem "aws-s3", :require => "aws/s3"
    
Next let's assume we have a User model and we want to allow our users to upload an avatar.

**Rails.root/app/models/user.rb**

    class User
      include Mongoid::Document
      include Mongoid::Paperclip
      
      has_attached_file :avatar
    end


And there you go!
-----------------

As you can see you use it in practically the same as when you use vanilla Paperclip. However, since we're using Mongoid and not ActiveRecord, we do not have a schema or any migrations. So with **Mongoid::Paperclip** when you invoke the `has_attached_file :avatar` it will create the necessary Mongoid **fields** for the specified attribute (`:avatar` in this case).


A more complex example
----------------------

Just like vanilla Paperclip, Mongoid::Paperclip takes a second argument (hash of options) for the `has_attached_file` method, so you can do more complex things such as in the following example.

    class User
      include Mongoid::Document
      embeds_many :pictures
    end
    
    class Picture
      include Mongoid::Document
      include Mongoid::Paperclip
      
      embedded_in :user, :inverse_of => :pictures
      
      has_attached_file :attachment,
        :path           => ':attachment/:id/:style.:extension',
        :storage        => :s3,
        :url            => ':s3_alias_url',
        :s3_host_alias  => 'something.cloudfront.net',
        :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
        :styles => {
          :original => ['1920x1680>', :jpg],
          :small    => ['100x100#',   :jpg],
          :medium   => ['250x250',    :jpg],
          :large    => ['500x500>',   :jpg]
        },
        :convert_options => { :all => '-background white -flatten +matte' }
    end

Quite a lot of people have been looking for a solution to use [Paperclip](https://github.com/thoughtbot/paperclip) with [Mongoid](http://mongoid.org/) so I hope this helps!

&copy; Copyright [Michael van Rooijen](http://michaelvanrooijen.com/)