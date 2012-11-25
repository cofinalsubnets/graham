class Graham::Cases
  def DocTest1; 4 + 5 end
  def DocTest2; 'test'.upcase end
  def DocTest3; 1/0  end
  def DocExample
    Graham.test { |that|
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
  that.DocExample.returns_a(Hash).of_size(3).such_that {
    self[:DocTest1] == true  and
    self[:DocTest2] == false and
    self[:DocTest3].is_a? ZeroDivisionError
  }
end

Graham.pp(:Namespace) do |that|
  that.Namespacing.is_such_that {
    self.class == Graham::Namespace
  }.and {!respond_to? :DocExample
  }.and { respond_to? :Namespacing}
end

