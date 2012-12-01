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

Graham.test!(Namespace.new) do |that|
  that.method(:namespacing).satisfies {|ret|
    Namespace === ret and
    ret.respond_to? :namespacing
  }
end

