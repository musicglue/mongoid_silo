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
# down to the default 'GrainBelt' generator. This will simply store all the attributes on your model,
# so you almost certainly don't want this. See below for more details.
silo

# Or you can specify the silo name and the class that will be called to populate it, like so...
silo :feed, generator: "MyGeneratorClass"

# To create a custom generator class, simply inherit from MongoidSilo::GrainBelt and override the
# generate method.
class MyGeneratorClass < MongoidSilo::GrainBelt
  def generate
    {
      name: name,
      age: age,
      dingbats: true
    }
  end
end
```
The generator class gets passed the instance of your model when the Silo is generated, and it exposes
your methods and attributes on that instance. Otherwise, you have access to the instance through the ```object``` accessor.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
