# Graham #

Graham is a tiny-yet-useful testing library based on Mallow - in fact it _is_ Mallow, with a tweaked DSL and some extra exception handling, bundled with a trivial pretty printer and a helper for Rake tasks. It was written to handle Mallow's unit tests because:
* Test::Unit was too ugly
* TestRocket was too minimal
* RSpec was too verbose (not to mention ridiculous overkill)

## How does one use graham ??? ##

Graham test cases are instance methods on arbitrary classes:
```ruby
  class Cases
    def initialize
      @number = 1
    end
    def one_squared
      @number ** 2
    end
    def dividing_one_by_zero
      @number / 0
    end
    def calling_upcase_on(obj)
      obj.upcase
    end
  end
```
Then test your cases:
```ruby
  Graham.test(Cases) do |that|
    that.one_squared.is 1
    that.dividing_by_zero.returns_a(Fixnum).such_that {|n| n > 1}
    that.calling_upcase_on(Graham).does_not_raise_an_exception
  end #=> {:one_squared=>true, :dividing_by_zero=>#<ZeroDivisionError>, :calling_upcase_on=>false}
```
Or use Graham::test! to run the results through Graham's pretty printer.

