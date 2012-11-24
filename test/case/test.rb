class Graham::Cases
  def DocTest1; 4 + 5 end
  def DocTest2; 'test'.upcase end
  def DocTest3; 1/0  end
  def DocExample
    Graham.ns { |that|
      that.DocTest1.returns_a(Fixnum).such_that {self < 100}
      that.DocTest2.returns 'TeST'
      that.DocTest3.returns_a Numeric
    }
  end
end

class Graham::Namespace
  def Namespacing; self end
end

Graham.pp do |that|
  that.DocExample.returns_an(Array).of_size(3).such_that {
    at(0)    == [:DocTest1, true ] and
    at(1)    == [:DocTest2, false] and
    at(2)[0] ==  :DocTest3         and
    at(2)[1].is_a? ZeroDivisionError
  }
end

Graham.pp(:Namespace) do |that|
  that.Namespacing.is_such_that {
    self.class == Graham::Namespace
  }.and {!respond_to? :DocExample
  }.and { respond_to? :Namespacing}
end

