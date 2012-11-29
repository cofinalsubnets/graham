$LOAD_PATH << File.dirname(__FILE__)
require 'mallow'
require 'graham/version'
# == A miniature test engine powered by Mallow
# ---
# Test cases are instance methods on arbitrary classes, and expectations on
# their return values are enumerated using a very slightly modified
# Mallow::DSL.
# 
#  class Cases
#    def four_plus_five
#      4 + 5 
#    end
#    def upcasing(s)
#      s.upcase
#    end
#    def one_divided_by_zero
#      1/0
#    end
#  end
#
#  Graham.test(Cases) { |that|
#    that.four_plus_five.is 9
#    that.upcasing('test').returns 'TeST'
#    that.one_divided_by_zero.equals :infinity
#  } #=> {:four_plus_five=>true, :upcasing=>false, :one_divided_by_zero=>#<ZeroDivisionError>}
#
# === N.B.
# Since a Graham test is basically a Mallow pattern matcher, only the first
# test on a case will actually be executed, as subsequent invocations of the
# test case will be matched by the first rule. This can lead to confusing
# results:
#
#  Graham.test(Cases) { |that|
#    that.four_plus_five.returns_a(Fixnum)
#    that.four_plus_five.returns_a(String)
#  } #=> {:four_plus_five=>true}
#
# To avoid this issue, either run separate tests:
#
#  Graham.test(Cases) {|that| that.four_plus_five.returns_a Fixnum} #=> {:four_plus_five=>true}
#  Graham.test(Cases) {|that| that.four_plus_five.returns_a String} #=> {:four_plus_five=>false}
# 
# Or (better) chain the tests you want to run:
# 
#  Graham.test(Cases) { |that|
#    that.four_plus_five.returns_a(Fixnum).that {is_a? String}
#  } #=> {:four_plus_five=>false}
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
    alias test! pp
  end

  class Core < Mallow::Core
    attr_reader :cases
    def initialize
      @cases = {}
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

    def test; Hash[_fluff @cases.keys] end
  end
end

