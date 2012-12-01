class ControlCases
  def the_number_99; 99 end
  def raising_a_name_error; raise Asdf.qwer.ty / 0 end
  def graham
    Graham.test(:test) {|that| that.it.is_a String } 
  end
end

Graham.test!(ControlCases.new) {|that|
  that.calling(:the_number_99).satisfies {|v|
    Fixnum === v and v == 99
  }
}

