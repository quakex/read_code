#!/usr/bin/env ruby

require_relative('lib/board')
require_relative('lib/queen')

def solve_queens_problem
  column = 0

  while column < @board.columns
    puts "\nTrying Queen ##{column+1}" if @verbose

    row = 0

    # Does this column already have a queen?
    last_queen = @board.queens.last
    if last_queen && last_queen.column == column
      # Then we must be backtracking. "Pick up" the current queen 
      # that didn't work out and resume our search on next row.
      puts "- Removing Queen ##{column+1}" if @verbose
      row = last_queen.row
      @board.remove_queen(column, row)
      row += 1
      
      # Problem: what if row + 1 >= @board.rows?
      if row >= @board.rows
        # If we get here, then we made it through all rows
        # without finding a safe position.
        puts "! No solution for Queen ##{column+1}, backtracking..." if @verbose
        column -= 1
        return if column < 0 # Prevent infinite looping
        next
      end
    end

    while row < @board.rows
      if @board.safe_position?(column, row)

        puts "+ Placing Queen ##{column+1} at #{column}, #{row}" if @verbose
        @board.place_queen(column, row)
        @board.display if @verbose
        
        if column == @board.ending_column
          # We placed the last queen!
          puts "! Solution Found\n" if @verbose
          @solution_found = true
          return # exit the function
        else
          # Possible solution, keep going!
          column += 1
          # stop looping through rows, go to next column
          break
        end
        
      else # not a safe position
        puts "x Conflict at #{column}, #{row}" if @verbose
        if row < @board.ending_row
          row += 1
          next # try the next row
        else
          # If we get here, then we made it through all rows
          # without finding a safe position.
          puts "! No solution for Queen ##{column+1}, backtracking..." if @verbose
          column -= 1
          return if column < 0 # Prevent infinite looping
          break
        end
      end
    end

  end

end

@verbose = true
@solution_found = false
@board = Board.new

solve_queens_problem

if @solution_found
  puts "\nSolution board:"
  @board.display
else
  puts "\nNo solutions found."
end
