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
      core.cases << (tc=TestCase.new @subj, msg, args, b)
      (conditions.empty?? self : rule!).__send__(:push) {|e|e==tc}
    end

    # Add a condition on a test case's return value. If the given block
    # has no parameters, it is evaluated in the context of the return
    # value.
    def where(&b)
      push {|e| preproc(b).call e.go }
    end

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

    def does_not_raise(x=nil)
      push {|tc|
        begin
          tc.go
          true
        rescue x => e
          false
        rescue   => e
          x ? raise(e) : false
        end
      }
    end

    def and(&b)
      b ? where(&b) : self
    end

    alias is      this
    alias returns this
    alias equals  this

    alias is_such_that where
    alias such_that    where
    alias that         and

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

    private
    def push(&p)
      conditions << p
      self
    end

    class TestCase < ::Struct.new(:obj, :msg, :args, :blk)
      def go
        defined?(@val) ? @val : (@val = obj.send msg, *args, &blk)
      end

      def to_s
        "#{msg}#{"(#{args.join ', '})" if args.any?} #{" {...}" if blk}"
      end
    end

  end
end

