#!/usr/bin/env ruby

require_relative('lib/board')
require_relative('lib/queen')

def solve_queens_problem
  place_queen_in_column(0)
end

def place_queen_in_column(column)
  puts "\nTrying Queen ##{column+1}" if @verbose

  @board.rows.times do |row|
    if @board.safe_position?(column, row)
      
      puts "+ Placing Queen ##{column+1} at #{column}, #{row}" if @verbose
      @board.place_queen(column, row)
      @board.display if @verbose
      
      if column == @board.ending_column
        # We placed the last queen!
        puts "! Solution Found\n" if @verbose
        
        # Add this board to the solutions
        add_board_to_solutions(@board)
        # but then proceed with looping/backtracking
        # to find next solution

      else
        # Possible solution, go deeper!
        place_queen_in_column(column+1)
      end
      
      # This portion of code can be tricky to wrap your 
      # head around. The #place_queen_in_column method 
      # either places a queen and goes deeper, or does nothing. 
      # On recursive calls, this code executes right after 
      # a deeper call does nothing. We are on the way "back up"
      # and are backtracking. We put down a queen here 
      # previously, but now we need to "pick it up" and try 
      # the next row.
      puts "- Removing Queen ##{column+1}" if @verbose
      @board.remove_queen(column, row)
      
    else # not a safe position
      puts "x Conflict at #{column}, #{row}" if @verbose
      next # try the next row
    end
  end
  
  # If we get here, then we made it through all rows 
  # without finding a safe position.
  # If we had found one, it would have either gone "deeper" 
  # to the next column (calling #place_queen_in_column again) 
  # or ended in success.
  puts "! No solution for Queen ##{column+1}, backtracking..." if @verbose
  
end

def add_board_to_solutions(board)
  # Store a copy of the board and the queens on it
  solution_board = Board.new
  solution_board.queens = board.queens.map(&:dup)
  @solution_boards << solution_board

  # Note that this would not work:
  #   solution_board.queens = @board.queens.dup
  # It duplicates the array, but not the queen objects 
  # in the array. And those queen objects are going to 
  # keep changing and be assigned new positions.
end

@verbose = false
@solution_boards = []
@board = Board.new

solve_queens_problem

if !@solution_boards.empty?
  @solution_boards.each_with_index do |solution_board, i|
    puts "\nSolution board #{i+1}:"
    solution_board.display
  end
else
  puts "No solutions found"
end
