module Graham
  # A trivial pretty printer for test output.
  # TODO: replace with something better
  class PP
    attr_reader :cases, :bt
    BOLD  = "\x1b[1m"
    PLAIN = "\x1b[0m"
    GREEN = "\x1b[32m"
    RED   = "\x1b[31m"
    def initialize(cases, bt=(ENV['backtrace']||0).to_i)
      @cases, @bt = cases, bt
    end
    def pp
      cases.each do |tc|
        m=if tc.pass
          [hi('PASS', GREEN), lo(tc.msg)]
        elsif tc.xptn
          [hi('XPTN', RED),   lo(tc.msg), tc.xptn.class.name, tc.xptn.message] + backtrace(tc.xptn)
        else
          [hi('FAIL', RED),   lo(tc.msg), display(tc)]
        end.join ' :: '
        puts m
      end
    end
    private
    def backtrace(e)
      bt>0 ? ["\n" << e.backtrace.first(bt).map {|s| "  "+s}.join("\n")] : []
    end

    def hi(str, c); BOLD+c+str.to_s  end
    def lo(str);    PLAIN+str.to_s  end

    def display(tc)
      "unexpected #{"instance of #{tc.go.class}" rescue "exception"}"
    end
  end
end
