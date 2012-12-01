module Graham
  class PP
    attr_reader :cases, :bt
    BOLD  = "\x1b[1m"
    PLAIN = "\x1b[0m"
    GREEN = "\x1b[32m"
    RED   = "\x1b[31m"
    def initialize(cases, bt=(ENV['backtrace']||0).to_i)
      @cases, @bt = cases, bt
    end

    def print
      cases.flatten.each do |tc|
        puts [pfx(tc),show(tc),backtrace(tc)].compact * ' :: '
      end
      cases
    end

    private
    def backtrace(tc)
      "\n" << e.backtrace.first(bt) * "\n" if tc.xptn and bt>0
    end

    def hi(str, c); BOLD+c+str+PLAIN end

    def show(tc)
      if Class === tc.obj
        "#{tc.obj}#{"::#{tc.msg}" if tc.msg}"
      else
        "#{tc.obj.class}#{"##{tc.msg}" if tc.msg}"
      end << "#{"(%s)" % tc.args.*(', ') if tc.args and tc.args.any?}"
    end

    def pfx(tc)
      if tc.pass
        hi 'PASS', GREEN
      elsif tc.xptn
        hi 'XPTN', RED
      else
        hi 'FAIL', RED
      end
    end
  end
end

