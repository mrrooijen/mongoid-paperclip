# Mongoid::Paperclip

Integrate [kt-paperclip](https://github.com/kreeti/kt-paperclip) into [Mongoid](http://mongoid.org/).
(Kt-paperclip is a maintained fork of the original [Paperclip](https://github.com/thoughtbot/paperclip) that is now deprecated)

This is actually easier and faster to set up than when using Paperclip and the ActiveRecord ORM.

## Setting it up

**Gemfile**

```rb
gem "mongoid-paperclip"
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

That's all you have to do. Users can now upload avatars. Unlike ActiveRecord, Mongoid doesn't use migrations, so we don't need to define the Paperclip columns in a separate file. Invoking `has_mongoid_attached_file` will automatically define the necessary `:avatar` fields for you.


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

## Optional fingerprinting

Paperclip will skip calculating the fingerprint of a file when the `{file}_fingerprint` field is missing from the model. This can be desirable if attaching large files to a model. To disable adding the fingerprint field pass the `disable_fingerprint` option as in this example:

```rb
class User
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :usage_report, disable_fingerprint: true
end
```

## Testing

If you want to help develop this plugin, clone the repo and bundle to get all dependencies.

Then to run the tests:

```
rspec
```

## There you go

Quite a lot of people have been looking for a solution to use Paperclip with Mongoid so I hope this helps!

If you need more information on either [Mongoid](http://mongoid.org/) or [kt-paperclip](https://github.com/kreeti/kt-paperclip) I suggest checking our their official documentation and website.

## License

Mongoid::Paperclip is released under the MIT license. See LICENSE for more information.
