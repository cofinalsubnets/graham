require 'graham/test_case'
module Graham
  class DSL < Mallow::BasicDSL
    include Mallow::DSL::Matchers
    def self.build_core(ns)
      yield(dsl = new(ns))
      dsl.send(:rule!).core
    end

    def initialize(ns)
      @core, @ns = Core.new, ns
      reset!
    end

    def method_missing(msg, *args, &b)
      case msg.to_s
      when /^((and|that)_)+(.+)$/
        respond_to?($3)? send($3, *args, &b) : super
      else
        _case @ns, msg, args, b
      end
    end

    # Add a condition on a test case's return value. If the given block
    # has no parameters, it is evaluated in the context of the return
    # value.
    def where(&b)
      push {|e| preproc(b).call e.go }
    end

    # Specify the subject for the next test.
    def subject(obj)
      TestCase::Proxy.new self, obj
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

    alias is      this
    alias returns this
    alias equals  this

    alias is_such_that where
    alias such_that    where
    alias that         where
    alias and          where

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

    alias []   subject

    private
    def push(&p)
      conditions << p
      self
    end

    def _case(obj, msg, args, blk)
      core.cases << (tc=TestCase.new obj, msg, args, blk)
      (conditions.empty?? self : rule!).send(:push) {|e|e==tc}
    end
  end
end

