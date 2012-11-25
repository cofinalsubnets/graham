class Graham::Cases
  def DocTest1; 4 + 5 end
  def DocTest2; 'test'.upcase end
  def DocTest3; 1/0  end
  def RDocExample
    Graham.test { |that|
      that.DocTest1.returns_a(Fixnum).such_that {self < 100}
      that.DocTest2.returns 'TeST'
      that.DocTest3.returns_a Numeric
    }
  end

  def initialize
    @number = 1
  end
  def ReadmeCase1
    @number ** 2
  end
  def ReadmeCase2
    @number / 0
  end
  def ReadmeCase3
    Graham.this_is_not_a_method
  end
  def ReadmeExample
    Graham.test do |that|
      that.ReadmeCase1.is_such_that { self == 1 }
      that.ReadmeCase2.is_a(Fixnum).such_that {self > 1}
      that.ReadmeCase3.does_not_raise_an_exception
    end 
  end
end

class Graham::Namespace
  def Namespacing; self end
end

Graham.pp do |that|
  that.RDocExample.returns_a(Hash).of_size(3).such_that {
    self[:DocTest1] == true  and
    self[:DocTest2] == false and
    self[:DocTest3].is_a? ZeroDivisionError
  }
  that.ReadmeExample.returns_a(Hash).of_size(3).such_that {
    self[:ReadmeCase1] == true and
    self[:ReadmeCase2].is_a? ZeroDivisionError and
    self[:ReadmeCase3] == false
  }
end

Graham.pp(:Namespace) do |that|
  that.Namespacing.is_such_that {
    self.class == Graham::Namespace
  }.and {!respond_to? :DocExample
  }.and { respond_to? :Namespacing}
end

