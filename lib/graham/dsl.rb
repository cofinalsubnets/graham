module Graham
  class DSL < Mallow::BasicDSL
    include Mallow::DSL::Matchers
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
    def where(&b);  _where {|e| preproc(b)[e.call] } end

    def _this(o);   _where {|e|e==o } end

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
    private
    def constantize(s)
      Object.const_get s.split(?_).map(&:capitalize).join
    end

  end
end
