# ImageMatcherStrategies contains methods that define the 
# match strategies that can be used by ImageMatcher.
module ImageMatcherStrategies

  @@strategies = {
    'full'          => :match_position_by_full_string,
    'rows'          => :match_position_by_pixel_rows,
    'pixels'        => :match_position_by_pixel_strings,
  }
  
  private
  
    # Compare images by converting all image pixels to a string.
    def match_position_by_full_string

      t_width = template_image.columns
      t_height = template_image.rows
      t_pixels = template_image.export_pixels_to_str(0, 0, t_width, t_height)

      catch :found_match do
        search_rows.times do |y|
          search_cols.times do |x|
          
            puts "Checking search image at #{x}, #{y}" if @verbose
            s_pixels = search_image.export_pixels_to_str(x, y, t_width, t_height)
            
            if s_pixels == t_pixels
              self.match_result = x, y
              throw :found_match
            end

          end
        end
      end # catch :found_match
      return match_result
    end

    # Compare images by converting first line pixels in each image
    # to a string. Checks next line only if first line matches.
    def match_position_by_pixel_rows

      catch :found_match do
        search_rows.times do |y|
          search_cols.times do |x|

            catch :try_next_position do
               puts "Checking search image at #{x}, #{y}" if @verbose

               template_image.rows.times do |j|

                 t_width = template_image.columns

                 # Just check first row, not full string
                 t_row = template_image.export_pixels_to_str(0, j, t_width, 1)
                 s_row = search_image.export_pixels_to_str(x, y+j, t_width, 1)

                 if s_row != t_row
                   # if any row doesn't match, move on.
                   throw :try_next_position
                 end

               end # template_image.columns.times do

               # Success! We made it through all rows 
               # at this position.
               self.match_result = x, y
               throw :found_match

             end # catch :try_next_position

          end
        end
      end # catch :found_match
      return match_result
    end

    # Compare images by converting first pixel in each image
    # to a string. Checks next pixel only if first pixel matches.
    def match_position_by_pixel_strings

      catch :found_match do
        search_rows.times do |y|
          search_cols.times do |x|

            catch :try_next_position do
              puts "Checking search image at #{x}, #{y}" if @verbose

              template_image.rows.times do |j|
                template_image.columns.times do |i|

                  t_pixel = template_image.export_pixels_to_str(i, j, 1, 1)
                  s_pixel = search_image.export_pixels_to_str(x+i, y+j, 1, 1)

                  if s_pixel != t_pixel
                    throw :try_next_position
                  end

                end # template_image.rows.times do
              end # template_image.columns.times do

              # Success! We made it through the whole 
              # template at this position.
              self.match_result = x, y
              throw :found_match

            end # catch :try_next_position

          end

        end
      end # catch :found_match
      return match_result
    end

end
