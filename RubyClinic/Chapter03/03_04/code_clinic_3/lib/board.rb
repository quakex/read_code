class Board

  DEFAULT_SIZE = 8

  attr_accessor :queens
  
  def initialize(options={})
    @size = options[:size] || DEFAULT_SIZE
    @queens = []
  end
  
  
  def rows
    @size
  end
  
  def starting_row
    0
  end

  def ending_row
    rows - 1
  end


  def columns
    @size
  end

  def starting_column
    0
  end
  
  def ending_column
    columns - 1
  end


  def place_queen(column=0, row=0)
    queen = Queen.new
    @queens << queen
    queen.column = column
    queen.row = row
    return queen
  end
  
  def remove_queen(column, row)
    queen = find_queen(column, row)
    if queen
      queen.column = nil
      queen.row = nil
      @queens.delete(queen)
    end
  end
  
  
  private
    
    def find_queen(column, row)
      @queens.detect {|q| q.location?(column, row)}
    end
    
end
