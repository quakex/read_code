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
  
  
  private
    
    def find_queen(column, row)
      @queens.detect {|q| q.location?(column, row)}
    end
    
    def contents_at(column, row)
      find_queen(column, row) || @@blank
    end
    
end
