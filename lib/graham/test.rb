module Graham
  module Test
    class Case < Struct.new :obj, :msg, :args, :blk, :exp, :pass, :xptn
      def test
        begin
          self.pass = msg ? exp[obj.send(msg, *args, &blk)] : exp[obj]
        rescue => e
          self.pass = false
          self.xptn = e
        end
        self
      end

      def with(h)
        c=dup
        h.each {|k,v| c.send("#{k}=",v)}
        c
      end
    end

    class Group < Array
      attr_reader :tc

      def initialize(c); @tc=c end

      def object(obj,&b)
        sub({obj: obj},&b)
      end

      def method(msg,&b)
        sub({msg: msg},&b)
      end

      def with(*args,&b)
        sub({args: args},&b)
      end

      def with_block(blk,&b)
        sub({blk: blk},&b)
      end

      def satisfies(&exp)
        sub(exp: exp)
      end

      def returns(v)
        satisfies {|r|r==v}
      end

      def does_not_return(v)
        satisfies {|r|r!=v}
      end

      def cases
        map {|n| n.any? ? n.cases : n.tc}
      end

      def each_case
        cs = cases.flatten
        block_given? ? cs.each {|c| yield c} : cs.each
      end

      def each_test
        ts = Enumerator.new {|y| each_case.each {|c| y << c.test }}
        block_given? ? ts.each {|t| yield t} : ts
      end

      def it
        method nil
      end

      alias calling method

      alias is      returns
      alias ==      returns
      alias is_not  does_not_return
      alias !=      does_not_return

      private
      def sub(h)
        g=Group.new tc.with h
        if block_given?
          yield g
          push g
        else
          push(g).last
        end
      end
    end
  end
end

