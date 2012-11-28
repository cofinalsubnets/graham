$LOAD_PATH << File.dirname(__FILE__)
require 'mallow'
require 'graham/version'
# == A miniature test engine powered by Mallow
# ---
# Test cases are instance methods on classes defined in Graham's namespace,
# and expectations on their return values are enumerated using a very slightly
# modified Mallow::DSL.
# 
#  class Graham::Cases
#    def test1; 4 + 5 end
#    def test2; 'test'.upcase end
#    def test3; 1/0 end
#  end
#
#  Graham.test { |that|
#    that.test1.returns_a(Fixnum).such_that {self < 100}
#    that.test2.returns 'TeST'
#    that.test3.returns_a Numeric
#  } #=> {:test1=>true, :test2=>false, :test3=>#<ZeroDivisionError>}
#
# === N.B.
# Since a Graham test is basically a Mallow pattern matcher, only the first
# test on a case will actually be executed, as subsequent invocations of the
# test case will be matched by the first rule. This can lead to confusing
# results:
#
#  Graham.test { |that|
#    that.test1.returns_a(Fixnum)
#    that.test1.returns_a(String)
#  } #=> {:test1=>true}
#
# To avoid this issue, either run separate tests:
#
#  Graham.test {|that| that.test1.returns_a Fixnum} #=> {:test1=>true}
#  Graham.test {|that| that.test1.returns_a String} #=> {:test1=>false}
# 
# Or (better) chain the tests you want to run:
# 
#  Graham.test { |that|
#    that.test1.returns_a(Fixnum).and_returns_a(String)
#  } #=> {:test1=>false}
#
module Graham
  autoload :PP,       'graham/pp'
  autoload :RakeTask, 'graham/rake_task'
  autoload :DSL,      'graham/dsl'
  class << self
    # A convenience method that builds and executes a Graham::Core
    # in the given namespace (defaults to Cases). See documentation for
    # Graham for more on usage.
    def test(ns, &b)
      DSL.build_core(ns, &b).test
    end
    # A convenience method that calls ::test and passes the output to a
    # pretty printer.
    def pp(ns, &b)
      PP.new(test ns,&b).pp
    end
  end

  class Core < Mallow::Core
    attr_accessor :cases
    def initialize
      @cases = []
      super
    end

    def _fluff1(e)
      [e] << begin
        super e
        true
      rescue Mallow::MatchException
        false
      rescue => err
        err
      end
    end

    def test; Hash[_fluff @cases] end
  end
end

