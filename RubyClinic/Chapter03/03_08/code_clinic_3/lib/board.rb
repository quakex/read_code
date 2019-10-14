class Board

  DEFAULT_SIZE = 8

  @@h_edge = '='
  @@v_edge = '|'
  @@blank  = '-'

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
  
  
  def display
    puts
    puts @@h_edge * (columns + 2)
    rows.times do |row|
      print @@v_edge
      columns.times do |column|
        print contents_at(column, row)
      end
      puts @@v_edge
    end
    puts @@h_edge * (columns + 2)
    puts
  end
  
  
  def safe_position?(column,row)
    return false unless safe_column?(column)
    return false unless safe_row?(row)
    return false unless safe_diagonal?(column, row)
    return true
  end
  
  
  private
    
    def find_queen(column, row)
      @queens.detect {|q| q.location?(column, row)}
    end
    
    def contents_at(column, row)
      find_queen(column, row) || @@blank
    end
    
    def safe_column?(column)
      queens.none? {|q| q.column == column}
    end
  
    def safe_row?(row)
      queens.none? {|q| q.row == row}
    end
  
    def safe_diagonal?(column, row)
      queens.none? do |q|
        (q.column - column).abs == (q.row - row).abs
      end
      # Examples:
      # (0,0) and (5,5) are obviously diagonal
      #   (0 - 5).abs == (0 - 5).abs
      # (0,7) and (6,1) are also diagonal
      #   (0 - 6).abs == (7 - 1).abs
      # (0,2) and (5,8) are not diagonal
      #   (0 - 5).abs != (2 - 8).abs
    end

end
