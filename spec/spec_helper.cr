require "spec"
require "../src/syringe"

# Injectables, both macro and wrapping variants
class IncludeInjectable
  Syringe.injectable
end

class WrapInjectable
end
Syringe.injectable(WrapInjectable)

# Providers, A variant where a new instance is returned,
# and a variant where a singleton is provided
class TestInstance
  @counter = 0

  def increment
    @counter = @counter + 1
  end

  def get_counter
    return @counter
  end
end

class SingletonTestInstance < TestInstance
end

class InstanceProvider
  Syringe.provide(TestInstance)

  def self.getInstance
    return TestInstance.new
  end
end

class SingletonProvider
  Syringe.provide(SingletonTestInstance)
  @@instance = SingletonTestInstance.new

  def self.getInstance
    return @@instance
  end
end

# Classes that get their dependencies injected, one where we
# include syringe, the other where the class is wrapped afterwards
class TInclude
  include Syringe
  Syringe.injectable
  def initialize(@i : IncludeInjectable)
  end

  def i
    return @i
  end
end

class TRegistered
  def initialize(@i : WrapInjectable)
  end

  def i
    return @i
  end
end
Syringe.wrap(TRegistered)

module Item
end

class Items
  include Syringe
  def initialize(@items : Array(Item))
  end

  def count
    @items.size
  end
end

class Item1
  include Item
  Syringe.injectable
end

class Item2
  include Item
  Syringe.injectable
end

class Item3
  include Item
  Syringe.injectable
end

module SomeModule
  class SomeClass
    Syringe.injectable
  end

  class SomeClass2
    include Syringe
    def initialize(@someclass : SomeClass)
    end
  end
end

class SomeClass3
  include Syringe
  def initialize(@someclass : SomeModule::SomeClass)
  end
end

module AnimalFarm
  module Animal
  end

  module Pets
    class Dog
      include Animal
      Syringe.injectable
    end

    class Cat
      include Animal
      Syringe.injectable
    end
  end

  module Livestock
    class Cow
      include Animal
      Syringe.injectable
    end
  end

  class Animals
    include Syringe
    def initialize(@items : Array(Animal))
    end

    def count
      @items.size
    end
  end

  module Special
    class Animals
      include Syringe
      def initialize(@items : Array(AnimalFarm::Animal))
      end

      def count
        @items.size
      end
    end
  end
end

module App
  module IDbClient1
  end
end

module App
  class IDbClient2
  end
end

module App
  abstract class IDbClient3
  end
end

class TestDbClient
  include App::IDbClient1
end

module App
  class AppDbClient < App::IDbClient2
  end
end

module App
  class OtherDbClient < App::IDbClient3
  end
end

module App
  class FooController1
    def initialize(@db_client : App::IDbClient1)
    end

    def injected_class
      @db_client.class
    end
  end
end

module App
  class FooController2
    def initialize(@db_client : App::IDbClient2)
    end

    def injected_class
      @db_client.class
    end
  end
end

module App
  class FooController3
    def initialize(@db_client : App::IDbClient3)
    end

    def injected_class
      @db_client.class
    end
  end
end

Syringe.injectable_as(TestDbClient, App::IDbClient1)
Syringe.injectable_as(App::AppDbClient, App::IDbClient2)
Syringe.injectable_as(App::OtherDbClient, App::IDbClient3)

Syringe.wrap(App::FooController1)
Syringe.wrap(App::FooController2)
Syringe.wrap(App::FooController3)

module App
  class FooController4
    include Syringe
    def initialize(@db_client : App::IDbClient3)
    end

    def injected_class
      @db_client.class
    end
  end
end

module App
  module App::DbClient4
  end
end

module App
  class ActualDbClient
    Syringe.injectable_as App::DbClient4
  end
end
