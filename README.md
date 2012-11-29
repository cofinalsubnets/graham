Graham
------

Graham is a small-but-strong testing library based on Mallow - in fact it _is_ Mallow, with a tweaked DSL and some extra exception handling, bundled with a trivial pretty printer and a helper for Rake tasks. It was written to handle Mallow's unit tests because:
* Test::Unit was too ugly
* TestRocket was too minimal
* RSpec was too verbose (not to mention ridiculous overkill)

Features
--------

* Dandy DSL
* Zero namespace pollution
* Hackable with a small code footprint
* Testing paradigm does not necessitate the gratuitous reinvention of such language features as inheritance, namespacing, and variable assignment (unlike some other frameworks that i sometimes have to use :/)

But how to use ???
----------------------

Graham test cases are just ordinary methods on arbitrary objects:
```ruby
  Graham.test {|that|
    that[1].even?.is true
  } #=> {#<TestCase ...> => false}
```
You can optionally specify a default receiver for tests:
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

  Graham.test(Cases.new) do |that|
    that.one_squared.is 1
    that.dividing_by_zero.returns_a(Fixnum).such_that {|n| n > 1}
    that.calling_upcase_on(Graham).does_not_raise_an_exception
  end
```
See RDoc documentation for more details on usage, and for information on how to use the Rake helper. Hint:
```ruby
  require 'graham/rake_task'
  Graham::RakeTask.new
  task default: :test
```


