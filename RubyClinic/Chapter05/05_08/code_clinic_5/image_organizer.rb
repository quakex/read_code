#!/usr/bin/env ruby

require 'mini_exiftool'

# Find images in target directory
#   Navigate to dir

this_dir = File.expand_path(File.dirname(__FILE__))
image_dir = File.join(this_dir, 'images')

#   Loop through contents
#   If item is file and image file, log it
#   If item is dir, recursively "find images in dir"

puts "*** Finding images"
images = Dir.glob('**/*.{jpg,jpeg,png,gif,tif}')
images.each do |image|
  puts "Found image: #{File.basename(image)}"
end

# Inspect images for metadata
#   Install software (exiftool, mini_exiftool)
#   Loop through each image
#   Read metadata
#   Extract caption from metadata

# Organize images by caption
#   Create new dir
#   Loop through images
#   If alpha-named dir does not exist, create it
#   Create a caption-named dir inside alpha-named dir
#   Copy image to caption-named dir

