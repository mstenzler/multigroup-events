module SetModelNameHelper
  class StiBaseClassNotDefinedError < ArgumentError; end

  def self.included(base)
#    @base = base
    base.extend(ClassMethods)
#    base.send :include, InstanceMethods
  end

  module ClassMethods
    # Used for STI so that a subclassed class can have the routes
    # of it's super class specified in sti_base_class method 
    # which is set in class including SetModelNameHelper
    def model_name
#      puts "self = #{self}, class= #{self.class}, class_name = #{self.class.name}"
      if self.methods.include? :sti_base_class
        base_class = self.sti_base_class
#        puts "Base class = #{base_class}"
#        puts "in model_name. name = #{base_class.model_name}"
        base_class.model_name
      else
        raise StiBaseClassNotDefinedError, "sti_base_class must be defined"
      end
    end
  end
end
