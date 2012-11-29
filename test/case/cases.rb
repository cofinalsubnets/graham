class TestCases
  def DocTest1; 4 + 5 end
  def DocTest2; 'test'.upcase end
  def DocTest3; 1/0  end
  def rdoc_example
    Graham.test(TestCases) { |that|
      that.DocTest1.returns_a(Fixnum).such_that {self < 100}
      that.DocTest2.returns 'TeST'
      that.DocTest3.returns_a(Numeric)
    }
  end

  def squaring(n)
    n ** 2
  end

  def dividing_by_zero(n)
    n / 0
  end
  def calling_a_nonexistent_method
    Graham.this_is_not_a_method
  end
  def readme_example
    Graham.test(TestCases) do |that|
      that.squaring(1).returns 1
      that.dividing_by_zero(1).returns_a(Fixnum)
      that.calling_a_nonexistent_method.does_not_raise_an_exception
    end 
  end
end

Graham.pp(TestCases) do |that|
  that.rdoc_example.returns_a(Hash).of_size(3).such_that {|h|
    h[:DocTest1] == true  and
    h[:DocTest2] == false and
    h[:DocTest3].is_a? ZeroDivisionError
  }
  that.readme_example.returns_a(Hash).of_size(3).such_that {|h|
    h[:squaring] == true and
    h[:dividing_by_zero].is_a? ZeroDivisionError and
    h[:calling_a_nonexistent_method] == false
  }
end

