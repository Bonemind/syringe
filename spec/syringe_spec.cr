require "./spec_helper"

class ChainedDependencies
  def initialize(@i : IncludeInjectable, @t : TInclude)
  end

  def i
    return @i
  end

  def t
    return @t
  end
end
Syringe.wrap(ChainedDependencies)

class ProvidedInstance
  def initialize(@i : TestInstance)
  end

  def i
    return @i
  end
end
Syringe.wrap(ProvidedInstance)

class SingletonProvidedInstance
  def initialize(@i : SingletonTestInstance)
  end

  def i
    return @i
  end
end
Syringe.wrap(SingletonProvidedInstance)

describe Syringe do
  it "should be able to inject when included" do
    t = TInclude.new
    t.i.should_not be_nil
  end

  it "should be able to inject when wrapped" do
    t = TRegistered.new
    t.i.should_not be_nil
  end

  it "should be able to resolve multiples and chains" do
    t = ChainedDependencies.new
    t.i.should_not be_nil
    t.t.should_not be_nil
  end

  it "should inject provided instances" do
    t = ProvidedInstance.new
    t.i.should_not be_nil
    t.i.increment
    t.i.increment

    t.i.get_counter.should eq(2)

    t = ProvidedInstance.new
    t.i.get_counter.should eq(0)
  end

  it "should inject provided singletons" do
    t = SingletonProvidedInstance.new
    t.i.should_not be_nil
    t.i.increment
    t.i.increment

    t.i.get_counter.should eq(2)

    t = SingletonProvidedInstance.new
    t.i.get_counter.should eq(2)
  end

  it "should allow arguments as array of classes that have mixin" do
    items = Items.new
    items.count.should eq(3)
  end

  it "should still work when using modules" do
    SomeClass3.new
    SomeModule::SomeClass2.new
  end

  it "should allow arguments as array of classes that have mixin when using array" do
    animals = AnimalFarm::Animals.new
    animals.count.should eq(3)
    animals = AnimalFarm::Special::Animals.new
    animals.count.should eq(3)
  end

  it "should use the only wrapped instance when using mixin" do
    App::FooController1.new.injected_class.should eq(TestDbClient)
    App::FooController2.new.injected_class.should eq(App::AppDbClient)
    App::FooController3.new.injected_class.should eq(App::OtherDbClient)
  end
end
