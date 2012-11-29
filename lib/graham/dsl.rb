module Graham
  class DSL < Mallow::BasicDSL
    include ::Mallow::DSL::Matchers
    def self.build_core(ns)
      yield(dsl = new(ns))
      dsl.__send__(:rule!).core
    end

    def initialize(subj)
      @core, @subj = ::Graham::Core.new, subj
      reset!
    end

    def method_missing(msg, *args, &b)
      _case msg, args, b
    end

    # Add a condition on a test case's return value. If the given block
    # has no parameters, it is evaluated in the context of the return
    # value.
    def where(&b)
      push {|e| preproc(b).call e.go }
    end

    # Expose the test object as a test case, so that the next condition
    # given will be applied directly to the object. The current implementation
    # is an egregious hack using Object#tap, which produces fairly
    # sub-optimal output through the pretty printer. This might make 
    # test specifications more semantic in some cases but it's probably better
    # to access the test object through its own methods instead.
    def it
      _case(:tap, [], ::Proc.new {})
    end

    # With a block _b_, equivalent to #where _b_. With no block and an
    # argument _a_, equivalent to #this(a).
    def is(a=nil,&b)
      b ? where(&b) : this(a)
    end

    # With an argument _x_, if the case raises an exception _e_ such that 
    # _x_ === _e_, returns true, else if the case raises no exception returns
    # false, else raises the exception. With no argument, returns true
    # if the case raises any exception, else false.
    def raises(x=nil)
      push {|tc|
        begin
          tc.go
          false
        rescue x => e
          true
        rescue   => e
          x ? raise(e) : true
        end
      }
    end

    # With an argument _x_, if the case raises an exception _e_ such that
    # _x_ === _e_, returns false; if the case raises no exception, returns
    # true; if the case raises an unexpected exception, raises the exception.
    # With no argument, returns true if no exception is raised, else raises
    # the exception.
    def does_not_raise(x=nil)
      push {|tc|
        begin
          tc.go
          true
        rescue x => e
          false
        end
      }
    end

    # With a block _b_, equivalent to #where _b_. With no block, returns self
    # for semantic test chaining.
    def and(&b)
      b ? where(&b) : self
    end

    alias that and

    alias returns this
    alias equals  this

    alias is_such_that where
    alias such_that    where

    alias raises_an           raises
    alias raises_a            raises
    alias raises_an_exception raises

    alias does_not_raise_a            does_not_raise
    alias does_not_raise_an           does_not_raise
    alias does_not_raise_an_exception does_not_raise

    alias is_a       a
    alias is_an      a
    alias returns_a  a
    alias returns_an a

    protected
    def push(&p)
      conditions << p
      self
    end

    private
    def _case(msg,args,b)
      core.cases << (tc=TestCase.new @subj, msg, args, b, core.cases.size)
      rule!.push {|e|e==tc}
    end

    class TestCase < ::Struct.new(:obj, :msg, :args, :blk, :id)
      def go
        defined?(@val) ? @val : (@val = obj.send msg, *args, &blk)
      end

      def to_s
        "#{msg}#{"(#{args.join ', '})" if args.any?} #{" {...}" if blk}"
      end
    end

  end
end

