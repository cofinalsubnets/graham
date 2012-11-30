require 'mallow'
require 'graham/version'
# == A miniature test engine powered by Mallow
# ---
# Test cases are methods on arbitrary objects, and expectations on 
# their return values are enumerated using a modified Mallow::DSL.
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
module Graham
  autoload :PP,       'graham/pp'
  autoload :RakeTask, 'graham/rake_task'
  autoload :DSL,      'graham/dsl'
  class << self
    def test(ns, &b)
      core, cases = DSL.build_core(ns, &b)
      cases.map do |tc|
        begin
          core.fluff1 tc
        rescue => e
          tc.pass=false
          tc.xptn=e
          tc
        end
      end
    end
    # A convenience method that calls ::test and passes the output to a
    # pretty printer.
    def test!(ns, &b)
      PP.new(test ns,&b).pp
    end
    alias pp test!
  end
end

