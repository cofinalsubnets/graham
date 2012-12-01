class Arguments
  def doubling(n)
    2*n
  end
end

Graham.test!(Arguments.new) {|that|
  that.calling(:doubling).with(2) == 4
}
