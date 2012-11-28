class Namespace
  def initialize
    @num=0
  end

  def namespacing; self end

  def initialization
    @num+=1
  end

  def reinitialization
    @num+=1
  end
end

Graham.pp(Namespace) do |that|
  that.namespacing.is_such_that {
    self.class == Namespace
  }.and {!respond_to? :rdoc_example
  }.and { respond_to? :namespacing}

  that.initialization.is 1
  that.reinitialization.is 1
end

