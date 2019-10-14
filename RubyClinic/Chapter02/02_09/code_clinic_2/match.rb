#!/usr/bin/env ruby

require_relative('image_matcher/image_matcher.rb')

# Where are the images to compare located?
this_dir = File.expand_path(File.dirname(__FILE__))
image_dir = File.join(this_dir, 'images')

# Which images should be compared?
# Larger image listed first.
image_tests = [
  # ['haystack.png', 'needle.png'],             # Parrots (72dpi PNG)
  ['460249177.jpg', '460249177a.jpg'],      # Parrots (300dpi JPG)
  # ['460249177.jpg', '477899129.jpg'],       # Parrots
  # ['78771293.jpg', '78771293a.jpg'],        # Wedding
  # ['103992931.jpg', '168680522.jpg'],       # Beach
  # ['478946583.jpg', '478946583a.jpg'],      # Statue of Liberty
  # ['186661962.jpg', '186661962_gray.jpg'],  # Circle with 2
]

image_tests.each_with_index do |test_set, i|
  puts
  puts "----- Image Set #{i+1} -----"
  puts "Does '#{test_set[0]}' contain '#{test_set[1]}'?"
  
  search_image_path = File.join(image_dir, test_set[0])
  template_image_path = File.join(image_dir, test_set[1])
  
  im = ImageMatcher.new
  im.search_image = search_image_path
  im.template_image = template_image_path
  im.verbose = true
  im.strategy = 'similar'
  im.fuzz = 0.0
  im.highlight_match = true
  im.match!

  if im.has_match?
    puts "\nYes. Matches at: " + im.match_result.join("/")
  else
    puts "\nNo match."
  end
  puts "\nSearch time using '#{im.strategy}': #{im.benchmark.total} seconds\n"
  
  puts "-" * 24
  puts
end
