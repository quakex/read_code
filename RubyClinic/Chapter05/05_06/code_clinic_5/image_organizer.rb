#!/usr/bin/env ruby

# Find images in target directory
#   Navigate to dir

this_dir = File.expand_path(File.dirname(__FILE__))
image_dir = File.join(this_dir, 'images')

#   Loop through contents
#   If item is file and image file, log it
#   If item is dir, recursively "find images in dir"

puts "*** Finding images"

@image_exts = ['.jpg', '.jpeg', '.gif', '.png', '.tif']

require 'pathname'

def gather(path)
  path.children.collect do |child|
    if child.file? && @image_exts.include?(File.extname(child))
      child
    elsif child.directory?
      # go deeper
      gather(child)
    end
  end.flatten.compact
end

image_path = Pathname.new(image_dir)
images = gather(image_path)
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

