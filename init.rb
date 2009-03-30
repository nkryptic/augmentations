# "Augmentations" plugin for Rails.
# By Henrik Nyh <http://henrik.nyh.se> for DanceJam <http://dancejam.com> 2008-09-10.
# Free to modify and redistribute with credit.
# See README for usage.

class ::AugmentationModule < ::Module
  attr_reader :augmentation
  
  def included(klass)
    raise "Cannot 'include' an AugmentationModule: use 'augment' instead."
  end
  
  def initialize(&block)
    @augmentation = block
  end
end

class ::Object
  def self.augment(*mods)
    @options_during_augmentation = mods.last.is_a?(::Hash) ? mods.pop : {}
    def self.options_during_augmentation
      @options_during_augmentation.dup
    end
    
    mods.each do |mod|
      raise ::ArgumentError.new("#{mod.name} is not an AugmentationModule") unless mod.is_a?(::AugmentationModule)
      class_eval &mod.augmentation if mod.augmentation
    end
    
    remove_instance_variable(:@options_during_augmentation)
    (class<<self; self; end).send :remove_method, :options_during_augmentation
  end
  
  def augmentation_module(modname=nil, &block)
    newmod = ::AugmentationModule.new(&block)
    
    who = respond_to?(:const_set) ? self : ::Kernel
    who.const_set( modname, newmod ) if modname
    
    newmod
  end
  private :augmentation_module
end
