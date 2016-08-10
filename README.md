# Mongoid::Paperclip

Integrate [Paperclip](https://github.com/thoughtbot/paperclip) into [Mongoid](http://mongoid.org/).

This is actually easier and faster to set up than when using Paperclip and the ActiveRecord ORM. This example assumes you are using **Ruby on Rails 3** and **Bundler**. However it doesn't require either.

## Setting it up

Simply define the `mongoid-paperclip` gem inside your `Gemfile`. Additionally, you can define the `aws-sdk` gem if you want to upload your files to Amazon S3. *You do not need to explicitly define the `paperclip` gem itself, since this is handled by `mongoid-paperclip`.*

**Rails.root/Gemfile - Just define the following:**

```rb
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem 'aws-sdk', '~> 1.3.4'
```

Next let's assume we have a User model and we want to allow our users to upload an avatar.

**Rails.root/app/models/user.rb - include the Mongoid::Paperclip module and invoke the provided class method**

```rb
class User
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :avatar
end
```

## That's it

That's all you have to do. Users can now upload avatars. Unlike ActiveRecord, Mongoid doesn't use migrations, so we don't need to define the Paperclip columns in a separate file. Invoking the `has_mongoid_attached_file` method will automatically define the necessary `:avatar` fields for you in the background.


## A more complex example

Just like Paperclip, Mongoid::Paperclip takes a second argument (hash of options) for the `has_mongoid_attached_file` method, so you can do more complex things such as in the following example.

```rb
class User
  include Mongoid::Document
  embeds_many :pictures
end

class Picture
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :user, :inverse_of => :pictures

  has_mongoid_attached_file :attachment,
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

@user.pictures.each do |picture|
  <%= picture.attachment.url %>
end
```

Note on embedded documents: if you plan to save or update the parent document, you MUST add cascade_callbacks: true to your
embeds_XXX statement.  Otherwise, your data will be updated but the paperclip functions will not run to copy/update your file.

In the above example:

```ruby
class User
  embeds_many :pictures, :cascade_callbacks => true
  accepts_nested_attributes_for :pictures, ...
  attr_accepted :pictures_attributes, ...
end

@user.update_attributes({ ... :pictures => [...] })
```

## Testing

If you want to help develop this plugin, clone the repo and bundle to get all dependencies.

Then to run the tests:

```
rspec
```

## There you go

Quite a lot of people have been looking for a solution to use Paperclip with Mongoid so I hope this helps!

If you need more information on either [Mongoid](http://mongoid.org/) or [Paperclip](https://github.com/thoughtbot/paperclip) I suggest checking our their official documentation and website.

## License

Mongoid::Paperclip is released under the MIT license. See LICENSE for more information.
