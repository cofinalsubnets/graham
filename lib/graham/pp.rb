# A trivial pretty printer for test output.
# TODO: replace with something better
class Graham::PP
  Bold  = "\x1b[1m"
  Plain = "\x1b[0m"
  Green = "\x1b[32m"
  Red   = "\x1b[31m"
  attr_reader :results
  attr_accessor :bt, :out, :color
  def initialize(results, bt=0, out=$stdout, color=true)
    @results, @bt, @out, @color = results, bt, out, color
  end
  def pp
    results.each do |name, result|
      out.puts case result
      when true
        [hi('PASS', Green), lo(name)]
      when false
        [hi('FAIL', Red),   lo(name)]
      else
        [hi('XPTN', Red),   lo(name), result.class.name, result.message] + backtrace(result)
      end.join ' :: '
    end
  end
  def self.[](results, bt=0, out=$stdout, color=true)
    new(results, bt, out, color).pp
  end

  private
  def backtrace(e,n)
    n>0 ? ["\n" << indent(e.backtrace.first(n)).join("\n")] : []
  end

  def indent(s)
    s.is_a?(Array) ? s.map {|s| indent s} : "  #{s}"
  end

  def hi(str, c); (color ? Bold+c : '')+str.to_s  end
  def lo(str);    (color ? Plain  : '')+str.to_s  end
end
