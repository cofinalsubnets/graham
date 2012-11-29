class ControlCases
  def the_number_99; 99 end
  def raising_a_name_error; raise Asdf.qwer.ty / 0 end
end

Graham.pp(ControlCases.new) {|that|
  that.the_number_99.returns_a(Fixnum).such_that {self==99}.and_that_is 99
  that.raising_a_name_error.raises.and_raises_a NameError
}

