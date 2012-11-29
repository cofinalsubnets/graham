class ControlCases
  def the_number_99; 99 end
  def raising_a_name_error; raise Asdf.qwer.ty / 0 end
  def graham
    Graham.test(:test) {|that| that.it.is_a String } 
  end
end

Graham.pp(ControlCases.new) {|that|
  that.the_number_99.returns_a(Fixnum).that.equals 99
  that.raising_a_name_error.raises.and.raises_a(NameError)
  that.graham.returns_a(Hash).such_that { size == 1 and values.first == false }
}

