#!/usr/bin/env ruby

require_relative('lib/board')
require_relative('lib/queen')

def solve_queens_problem
  @board.columns.times do |column|
    puts "\nTrying Queen ##{column+1}" if @verbose

    @board.rows.times do |row|
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
          # Stop looping through rows, go to next column
          break
        end
        
      else # not a safe position
        puts "x Conflict at #{column}, #{row}" if @verbose
        if row < @board.ending_row
          next # try the next row
        else
          # If we get here, then we made it through all rows
          # without finding a safe position.
          puts "! No solution for Queen ##{column+1}, backtracking..." if @verbose
          # Problem: Can't go back a column
          # Loop keeps going to next column...
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
