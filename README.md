# Syringe

[![Build Status](https://travis-ci.org/Bonemind/syringe.svg?branch=master)](https://travis-ci.org/Bonemind/syringe)[![Build Status](https://travis-ci.org/Bonemind/syringe.svg?branch=master)](https://travis-ci.org/Bonemind/syringe)

A simple and basic dependency injection shard for crystal

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  syringe:
    github: Bonemind/syringe
```

## Usage

### Use case

Syringe attempts to provide dependency injection for crystal. This allows
a class to define a type it expects an instance of, without having to add
it when constructing the class for example, instead, an instance gets provided
automatically when a class is instantiated.

This allows you to decouple implementation from interface and manage your dependencies
in a more flexible way. If a class expects a `DbClient` for example, you could
automatically inject a `TestDbClient` when running tests, while inserting
your `PostgresDbClient` in other environments. This can be achieved without the rest
of your code being any wiser.

```crystal
# spec_helper.cr
class TestDbClient : DbClient
end

Syring.injectable(TestDbClient)

# main.cr
Syring.injectable(PostgresDbClient)

# foo_controller.cr
class FooController
  include Syringe

  def initialize(@db_client : DbClient)
  end
end
```

### Code

```crystal
require "syringe"
```

The basic idea behind syringe is that on one hand, you tell the module
what instances can be injected, and on the other hand, register classes
that need to have things injected into them (these can then be injected
somewhere else).

To mark classes for injection, you have one of two options:

```crystal
require "syringe"

class A
  Syringe.injectable
end

class B
end

Syringe.injectable(B)
```

Now Syringe is aware of these classes and you can inject them somewhere else in
your application.  To mark a class as syringe-injected you can either include Syringe in
the class, or `wrap` the class, both of which generate a `new` method that provides
the instances as requested by the `initialize` function:

```crystal
class C
  include Syringe

  def initialize(@a : A, @boo : B)
  end
end

class D
  def initialize(@c : C)
  end
end

Syringe.wrap(D)

C.new # will now have an instance of A as @a and B as @boo

D.new # will have an instance of C with C having A and B instances
```

If you need more control of how the dependencies are instantiated, you can
mark providers for certain classes which will be used when a class is requested.
This class has to implement a `getInstance` class method that returns an instance
of the provided class.

```crystal
class T
  def new(@i_num : Int32)
  end
end

class TProvider
  Syringe.provide(T)
  @@i_num = 0

  def getInstance
    @@i_num = @@i_num + 1
    return T.new(@@i_num)
  end
end

class Q
  def initialize(@t : T)
  end
end

Syringe.wrap(Q)

q = Q.new # t.i_num will be 1
q2 = Q.new # t.i_num will be 2
```

If you want to inject an array of descendants you can specify
`Array(T)` as the argument type

```crystal
module Animal
  abstract def say(sentence : string)
end

class Animals
  include Syringe
  def initialize(@animals : Array(Animal)
  end

  def say(sentence : string)
    @animals.each do |animal|
      animal.say(sentence)
    end
  end
end

class Dog
  Syringe.injectable
  include Animal

  def say(sentence : string)
    puts "Woof! #{sentence}"
  end
end

class Cat
  Syringe.injectable
  include Animal

  def say(sentence : string)
    puts "Meow! #{sentence}"
  end
end

animals = Animals.new
animals.say("Hi")
```

This would output

```
Woof! Hi
Meow! Hi
```

## Development

Syringe has no external dependencies, so simply clone the repository
and get started. Tests can be run by:

```
crystal spec
```

## Contributing

1. Fork it (<https://github.com/Bonemind/syringe/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Bonemind](https://github.com/Bonemind) Subhi Dweik - creator, maintainer
- [elliotize](https://github.com/elliotize) elliotize - Array descendants
