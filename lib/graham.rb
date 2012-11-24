$LOAD_PATH << File.dirname(__FILE__)
require 'mallow'
require 'graham/version'
# = A test engine powered by Mallow
# ---
# Test cases are instance methods on classes defined in Graham's namespace,
# and expectations on their return values are enumerated using a very slightly
# modified Mallow::DSL.
# 
#  class Graham::TestCases
#    def test1; 4 + 5 end
#    def test2; 'test'.upcase end
#    def test3; 1/0 end
#  end
#
#  Graham.ns(:TestCases) { |that|
#    that.test1.returns_a(Fixnum).such_that {self < 100}
#    that.test2.returns 'TeST'
#    that.test3.returns_a Numeric
#  } #=> [[:test1, true], [:test2, false], [:test3, #<ZeroDivisionError>], [:test1, true]]
# TODO:
# * some kind of helper for concurrent expectation chains
module Graham
  autoload :PP, 'graham/pp'
  # Namespace for test cases; see documentation for Graham
  class Cases; end
  class << self
    # A convenience method that builds and executes a Graham::Cracker
    # in the given namespace (defaults to Cases). See documentation for
    # Graham for more on usage.
    def ns(ns=self::Cases, &b)
      ns=const_get(ns) if ns.is_a? Symbol
      Graham::Cracker.build(ns, &b).test
    end
    # A convenience methods that calls ::ns and passes the output to a
    # pretty printer.
    def pp(ns=self::Cases, &b)
      PP[ self.ns ns,&b ]
    end
  end

  class Cracker < Mallow::Core
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

    def test; _fluff @cases end
    def self.build(ns, &b); DSL.build ns, &b end
  end

  class DSL < Mallow::DSL

    def self.build(ns)
      yield(dsl = new(ns))
      dsl.finish!
    end

    def initialize(ns)
      @core, @cases = Cracker.new, ns.new
      reset!
    end

    def method_missing(msg, *args, &b)
      case msg.to_s
      when /^(and|that)_(.+)$/
        respond_to?($2)? send($2, *args, &b) : super
      else
        core.cases << (_case = @cases.method msg) rescue super
        rule!._this _case
      end
    end

    def where(&b);  super {|e| preproc(b)[e.call] } end
    def _this(o);   _where {|e|e==o}    end
    def _where(&b); push b, :conditions end

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

    alias is      this
    alias returns this
    alias that_is this

    alias is_such_that where
    alias such_that    where
    alias and          where

    alias raises_an           raises
    alias raises_a            raises
    alias raises_an_exception raises

    alias is_a       a
    alias is_an      a
    alias returns_a  a
    alias returns_an a

  end
end
