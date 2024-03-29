Graham
------

Graham is a small-but-strong testing library based on Mallow, with a heavily tweaked DSL and some extra exception handling, bundled with a trivial pretty printer and a helper for Rake tasks. It was written to handle Mallow's unit tests out of sheer perversity and also because:
* Test::Unit was too ugly
* TestRocket was too minimal
* RSpec was too verbose (not to mention ridiculous overkill)

Features
--------

* Dandy DSL
* Zero namespace pollution
* Hackable with a small code footprint ( Graham + Mallow < 350 SLOC )
* Testing paradigm does not necessitate the gratuitous reinvention of such language features as inheritance, namespacing, and variable assignment (unlike some other frameworks that i sometimes have to use :/)

Installation
------------

```shell
  gem install graham
```

But how to use ???
------------------

Graham test cases are just ordinary methods on arbitrary objects:
```ruby
  Graham.test(500) {|that|
    that.it.is_a(Fixnum).and.that.it.is {even?}
  } #=> {#<TestCase ...> => true, #<TestCase ...> => true}
```
You can inline all your tests if you want to, but a less reckless approach (and one that coaxes nicer output out of the pretty printer) looks like:
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

  Graham.test(Cases.new) {|that|
    that.one_squared.is 1
    that.dividing_one_by_zero.returns_a(Fixnum).such_that {|n| n > 1}
    that.calling_upcase_on(Graham).does_not_raise_an_exception
  } #=> pass, caught exception, fail
```
See RDoc documentation for more details on usage, and for information on how to use the Rake helper.
```ruby
  # hint:
  require 'graham/rake_task'
  Graham::RakeTask.new
  task default: :test
```

