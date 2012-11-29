module Graham
  # A trivial pretty printer for test output.
  # TODO: replace with something better
  class PP
    attr_reader :results
    attr_accessor :bt, :out, :color
    BOLD  = "\x1b[1m"
    PLAIN = "\x1b[0m"
    GREEN = "\x1b[32m"
    RED   = "\x1b[31m"
    def initialize(results, bt=(ENV['backtrace']||0).to_i, out=$stdout, color=true)
      @results, @bt, @out, @color = results, bt, out, color
    end
    def pp
      results.each do |tc, result|
        out.puts case result
        when true
          [hi('PASS', GREEN), lo(tc)]
        when false
          [hi('FAIL', RED),   lo(tc), display(tc)]
        else
          [hi('XPTN', RED),   lo(tc), result.class.name, result.message] + backtrace(result, bt)
        end.join ' :: '
      end
    end
    private
    def backtrace(e,n)
      n>0 ? ["\n" << e.backtrace.first(n).map {|s| "  "+s}.join("\n")] : []
    end

    def hi(str, c); (color ? BOLD+c : '')+str.to_s  end
    def lo(str);    (color ? PLAIN  : '')+str.to_s  end

    def display(tc)
      "got an unexpected #{"instance of #{tc.go.class}" rescue "exception"}"
    end
  end
end
