module Graham
  # A struct for encapsulating test cases. Memoizes the case's return
  # value.
  class TestCase < Struct.new(:obj, :msg, :args, :blk)
    def go
      defined?(@val) ? @val : (@val = obj.send msg, *args, &blk)
    end

    def to_s
      "#{Class===obj ? '::' : ?#}#{msg}(#{args.join ', '})#{" {...}" if blk}"
    end

    # Delegator to create test cases out of methods that would otherwise
    # mistakenly be called on a DSL instance.
    class Proxy < BasicObject
      def initialize(dsl,obj)
        @dsl,@obj=dsl,obj
      end

      def method_missing(msg,*args,&blk)
        @dsl.send :_case,@obj,msg,args,blk
      end
    end
  end
end

