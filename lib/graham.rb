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
  autoload :Test,     'graham/test'

  class << self
    def test(obj,&b)
      c = Test::Group.new(Test::Case.new obj)
      yield c if block_given?
      c.test
    end

    def test!(obj,&b)
      PP.new(test(obj,&b)).print
    end
  end
end

