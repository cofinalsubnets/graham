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
  # Namespace for test cases; see documentation for Graham
  class Cases; end
  class << self
    # A convenience method that builds and executes a Graham::Core
    # in the given namespace (defaults to Cases). See documentation for
    # Graham for more on usage.
    def test(ns=self::Cases, &b)
      ns=const_get(ns) if ns.is_a? Symbol
      Graham::Core.build(ns, &b).test
    end
    # A convenience methods that calls ::test and passes the output to a
    # pretty printer.
    def pp(ns=self::Cases, &b)
      PP.new(test ns,&b).pp
    end

    def compose(ns=nil, *test_groups)

    end

    alias test_in test

    private
    def ns_compose(test_groups)
      test_groups.map do |ns, tests|
        [ ns, tests.map {|test| test ns, &test} ]
      end
    end

  end

  class Core < Mallow::Core
    attr_accessor :cases
    def initialize(*args)
      @cases = []
      super
    end

    def _fluff1(e)
      [e.name] << begin
        super e
        true
      rescue Mallow::DeserializationException
        false
      rescue => err
        err
      end
    end

    def test; Hash[_fluff @cases] end
    def self.build(ns, &b); DSL.build ns, &b end
  end

  class DSL < Mallow::DSL

    def self.build(ns)
      yield(dsl = new(ns))
      dsl.finish!
    end

    def initialize(ns)
      @core, @cases = Core.new, ns.new
      reset!
    end

    def method_missing(msg, *args, &b)
      case msg.to_s
      when /^((and|that)_)*(is|returns)_an?_(.+)$/
        is_a constantize $4
      when /^((and|that)_)+(.+)$/
        respond_to?($3)? send($3, *args, &b) : super
      else
        core.cases << (_case = @cases.method msg)
        rule!._this _case
      end
    end

    def _where(&b); push b, :conditions              end
    def _this(o);   _where {|e|e==o}                 end
    def where(&b);  _where {|e| preproc(b)[e.call] } end

    def raises(x=nil)
      _where {
        begin
          call
          false
        rescue x => e
          true
        rescue   => e
          x ? raise(e) : true
        end
      }
    end

    def does_not_raise(x=nil)
      _where {
        begin
          call
          true
        rescue x => e
          false
        rescue   => e
          x ? raise(e) : false
        end
      }
    end

    alias is      this
    alias returns this

    alias is_such_that where
    alias such_that    where
    alias and          where
    alias that         where

    alias raises_an           raises
    alias raises_a            raises
    alias raises_an_exception raises

    alias returns_                    does_not_raise
    alias does_not_raise_a            does_not_raise
    alias does_not_raise_an           does_not_raise
    alias does_not_raise_an_exception does_not_raise

    alias is_a       a
    alias is_an      a
    alias returns_a  a
    alias returns_an a

  end
end

