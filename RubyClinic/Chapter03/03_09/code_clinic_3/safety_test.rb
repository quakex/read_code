#!/usr/bin/env ruby

require_relative('lib/board')
require_relative('lib/queen')

@board = Board.new
@board.place_queen(0,0)
@board.place_queen(1,2)
@board.display

column = 2
@board.rows.times do |row|
  if @board.safe_position?(column,row)
    puts "Safe at (#{column}, #{row})"
  else
    puts "Conflict at (#{column}, #{row})"
  end
end
