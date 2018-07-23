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

