require 'mallow'
require 'graham/version'
# == A miniature test engine powered by Mallow
# ---
# Test cases are methods on arbitrary objects, and expectations on 
# their return values are enumerated using a slightly modified 
# Mallow::DSL.
# 
#  class MyCase
#    def upcasing(s)
#      s.upcase
#    end
#  end
#
#  Graham.test(MyCase.new) { |that|
#    that.upcasing('test').returns 'TeST'
#  } #=> {#<TestCase ...>=>false}
#
# The argument to Graham::test is optional, but if you include it,
# you don't need to specify test subjects. Compare:
#
#  Graham.test! { |that|
#    that[1].odd?.returns true
#    that['adsf'].is_a? String
#  }
#
module Graham
  autoload :PP,       'graham/pp'
  autoload :RakeTask, 'graham/rake_task'
  autoload :DSL,      'graham/dsl'
  autoload :TestCase, 'graham/test_case'
  class << self
    # A convenience method that builds and executes a Graham::Core
    # in the given namespace (defaults to Cases). See documentation for
    # Graham for more on usage.
    def test(ns=nil, &b)
      DSL.build_core(ns, &b).test
    end
    # A convenience method that calls ::test and passes the output to a
    # pretty printer.
    def pp(ns=nil, &b)
      PP.new(test ns,&b).pp
    end
    alias test! pp
  end

  class Core < Mallow::Core
    attr_reader :cases
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

