class Queen

  attr_accessor :column, :row
  
  def location
    [column, row]
  end
  
  def location?(x,y)
    location == [x,y]
  end
  
end
