# Graham #

Graham is a tiny-yet-useful testing library based on Mallow - in fact it _is_ Mallow, with a tweaked DSL and some extra exception handling, bundled with a trivial pretty printer and a helper for Rake tasks. It was written to handle Mallow's unit tests because:
* Test::Unit was too ugly
* TestRocket was too minimal
* RSpec was too verbose (not to mention ridiculous overkill)

## How i graham ##

Graham test cases are instance methods on classes defined in Graham's namespace:
```ruby
  class Graham::TestCases
    def initialize
      @number = 1
    end
    def Case1
      @number ** 2
    end
    def Case2
      @number / 0
    end
    def Case3
      Graham.this_is_not_a_method
    end
  end
```
Then test your cases:
```ruby
  Graham.test(:TestCases) do |that|
    that.Case1.is_such_that { self == 1 }
    that.Case2.is_a(Fixnum).such_that {self > 1}
    that.Case3.does_not_raise_an_exception
  end #=> {:Case1=>true, :Case2=>#<ZeroDivisionError>, :Case3=>false}
```
Calling Graham#pp instead will call Graham#test and run the output through Graham's built-in pretty printer.

