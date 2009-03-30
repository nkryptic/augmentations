require 'test/unit'
require File.join(File.dirname(__FILE__), '../init')

class ModelBase
  def self.belongs_to(x) @belongs_to = x end
  def self.has_one(x) @has_one = x end
  def self.nested_belongs_to(x) @nested_belongs_to = x end
  def self.nested_has_one(x) @nested_has_one = x end
end

augmentation_module :ModuleOne do
  belongs_to :test
  def an_instance_method?() true end
  def self.belongs_to?(x) @belongs_to == x end
end

ModuleTwo = augmentation_module do
  has_one :test
  def another_instance_method?() true end
  def self.has_one?(x) @has_one == x end
end

augmentation_module :ModuleWithArgs do
  if options_during_augmentation[ :auth_by_password ]
    def self.authentication_methods() [:password, :cookie, :session] end
  else
    def self.authentication_methods() [:cookie, :session] end
  end
end

module OuterModule
  augmentation_module :InnerModuleOne do
    nested_belongs_to :test
    def a_nested_instance_method?() true end
    def self.nested_belongs_to?(x) @nested_belongs_to == x end
  end
  
  InnerModuleTwo = augmentation_module do
    nested_has_one :test
    def another_nested_instance_method?() true end
    def self.nested_has_one?(x) @nested_has_one == x end
  end
end

class MyModel < ModelBase
  augment ModuleOne, ModuleTwo, OuterModule::InnerModuleOne, OuterModule::InnerModuleTwo
end

class MyArgModelOne
  augment ModuleWithArgs
end

class MyArgModelTwo
  augment ModuleWithArgs, :auth_by_password => true
end


class AugmentationsTest < Test::Unit::TestCase
  
  def test_calling_and_defining_class_methods
    assert MyModel.belongs_to?(:test)
    assert MyModel.has_one?(:test)
    assert MyModel.nested_belongs_to?(:test)
    assert MyModel.nested_has_one?(:test)
  end
  
  def test_defining_instance_methods
    my_model = MyModel.new
    assert my_model.an_instance_method?
    assert my_model.another_instance_method?
    assert my_model.a_nested_instance_method?
    assert my_model.another_nested_instance_method?
  end
  
  def test_passing_module_arguments
    assert MyArgModelOne.authentication_methods == [:cookie, :session]
    assert MyArgModelTwo.authentication_methods == [:password, :cookie, :session]
  end

end
