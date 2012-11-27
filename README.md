# Graham #

Graham is a tiny-yet-useful testing library based on Mallow - in fact it _is_ Mallow, with a tweaked DSL and some extra exception handling, bundled with a trivial pretty printer and a helper for Rake tasks. It was written to handle Mallow's unit tests because:
* Test::Unit was too ugly
* TestRocket was too minimal
* RSpec was too verbose (not to mention ridiculous overkill)

## How does one graham ##

Graham test cases are instance methods on arbitrary classes:
```ruby
  class TestCases
    def initialize
      @number = 1
    end
    def one_squared
      @number ** 2
    end
    def dividing_one_by_zero
      @number / 0
    end
    def calling_a_nonexistent_method
      Graham.this_is_not_a_method
    end
  end
```
Then test your cases:
```ruby
  Graham.test(TestCases) do |that|
    that.one_squared.is 1
    that.dividing_by_zero.returns_a(Fixnum).such_that {self > 1}
    that.calling_a_nonexistent_method.does_not_raise_an_exception
  end #=> {:one_squared=>true, :dividing_by_zero=>#<ZeroDivisionError>, :calling_a_nonexistent_method=>false}
```
Calling Graham::pp instead will call Graham::test and run the output through Graham's built-in pretty printer.

