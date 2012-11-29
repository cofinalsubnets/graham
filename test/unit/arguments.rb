class Arguments
  def doubling(n)
    2*n
  end
end

Graham.pp(Arguments) {|that|
  that.doubling(2).equals 4
}
