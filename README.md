[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/musicglue/mongoid_silo) [![Build Status](https://travis-ci.org/musicglue/mongoid_silo.png?branch=master)](https://travis-ci.org/musicglue/mongoid_silo)
# MongoidSilo

MongoidSilo creates and transparently manages static representations of a model - e.g. for creating Feeds or other diverse datastructures.

It's pretty opinionated, and thus must be awesome. It requires the latest Mongoid and Sidekiq, mainly because they are both awesome, secondly because it uses them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_silo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_silo

## Usage

Include ```Mongoid::Silo``` in your model, and then declare your silos.

```ruby
# The default usage creates a "default" silo, accessable through instance#default_silo that will call
# an instance#to_silo method to populate itself on save.
silo

# Or you can specify the silo name and the method that will be called to populate it, like so...
silo :feed, :make_my_feed
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
