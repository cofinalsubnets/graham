class Namespace
  def namespacing; self end
end

Graham.pp(Namespace) do |that|
  that.namespacing.is_such_that {
    self.class == Namespace
  }.and {!respond_to? :rdoc_example
  }.and { respond_to? :namespacing}
end

