#!/usr/bin/env ruby

require_relative('lib/board')
require_relative('lib/queen')

@board = Board.new
@board.place_queen(0,0)
@board.place_queen(1,1)
@board.place_queen(2,6)
@board.place_queen(3,5)
@board.place_queen(4,7)
@board.place_queen(5,2)
@board.place_queen(6,4)
@board.place_queen(7,3)
@board.display
