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
          [hi('PASS', GREEN), lo(tc.to_s)]
        elsif tc.xptn
          [hi('XPTN', RED),   lo(tc.to_s), tc.xptn.class.name, tc.xptn.message] + backtrace(tc.xptn)
        else
          [hi('FAIL', RED),   lo(tc.to_s), display(tc)]
        end.join ' :: '
        puts m
      end
    end
    private
    def backtrace(e)
      bt>0 ? ["\n" << e.backtrace.first(bt).map {|s| "  "+s}.join("\n")] : []
    end

    def hi(str, c); BOLD+c+str  end
    def lo(str);    PLAIN+str   end

    def display(tc)
      "unexpected #{"instance of #{tc.go.class}" rescue "exception"}"
    end
  end
end
