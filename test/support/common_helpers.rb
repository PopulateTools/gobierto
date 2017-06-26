module CommonHelpers

  def array_match(expected, actual)
    expected.sort == actual.sort
  end

end
