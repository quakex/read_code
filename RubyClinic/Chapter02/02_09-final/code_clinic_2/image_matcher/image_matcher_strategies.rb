# ImageMatcherStrategies contains methods that define the 
# match strategies that can be used by ImageMatcher.
module ImageMatcherStrategies

  @@strategies = {
    'full'          => :match_position_by_full_string,
    'rows'          => :match_position_by_pixel_rows,
    'pixels'        => :match_position_by_pixel_strings,
    'fuzzy'         => :match_position_by_pixel_objects,
    'sad'           => :match_position_by_sad,
    'similar'       => :match_position_by_similar,
    'opencv'        => :match_position_by_opencv
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

    # Compare images by converting first pixel in each image 
    # to an RMagick Pixel object. Checks next pixel only if 
    # first pixel matches. Objects take longer to instantiate 
    # but offer more complex features.
    def match_position_by_pixel_objects
      qfuzz = QuantumRange * fuzz
      
      catch :found_match do
        search_rows.times do |y|
          search_cols.times do |x|

            catch :try_next_position do
              puts "Checking search image at #{x}, #{y}" if @verbose

              template_image.rows.times do |j|
                template_image.columns.times do |i|

                  # #pixel_color returns a Pixel object
                  # around 4x slower than export_pixels_to_str
                  t_pixel = template_image.pixel_color(i,j)
                  s_pixel = search_image.pixel_color(x+i,y+j)
                  
                  # Pixel objects allow fuzzy comparisions
                  # #fcmp returns true/false if pixels are close
                  if !s_pixel.fcmp(t_pixel, qfuzz)
                    throw :try_next_position
                  end

                end # template_image.rows.times do
              end # template_image.columns.times do

              # Success! We made it through the whole template
              # at this position.
              self.match_result = x, y
              throw :found_match

            end # catch :try_next_position

          end

        end
      end # catch :found_match
      return match_result
    end

    # Compare images by converting every pixel in the current 
    # search position to an RMagick Pixel object and then uses 
    # the intensity value to calculate the sum of absolute 
    # differences (SAD) for that position.
    # Keeps track of the best SAD so far (the closest match) 
    # as it moves across the entire search image and returns 
    # the best match found.
    # Takes longer because it scans entire image for "best match"
    # instead of quiting at "first match".
    def match_position_by_sad
      # SAD = "sum of absolute differences"
      best_sad = 1_000_000

      search_rows.times do |y|
        search_cols.times do |x|
          puts "Checking search image at #{x}, #{y}" if @verbose
          sad = 0.0

          template_image.rows.times do |j|
            template_image.columns.times do |i|
              s_pixel = search_image.pixel_color(x+i,y+j)
              t_pixel = template_image.pixel_color(i,j)

              # Could use pixel hue
              # #to_hsla returns [hue, saturation, lightness, alpha]
              # sad += (s_pixel.to_hsla[0] - t_pixel.to_hsla[0]).abs
              
              # Or pixel "intensity" which is computed as:
              # (0.299*R) + (0.587*G) + (0.114*B)
              sad += (s_pixel.intensity - t_pixel.intensity).abs
              
            end
          end

          # save if this is best position (least difference) so far
          if sad < best_sad
            puts "New best at #{x}, #{y}: #{sad}" if @verbose
            best_sad = sad
            self.match_result = x, y
          end

        end
      end

      return match_result

    end

    # Compare images using RMagick's built-in #find_similar_region 
    # method.
    def match_position_by_similar
      add_fuzz_to_images
      self.match_result = search_image.find_similar_region(template_image)
      return match_result
    end

    # Compare images using the OpenCV library (Open Source 
    # Computer Vision, http://opencv.org).
    def match_position_by_opencv
      t_image = CvMat.load(template_image.filename)
      s_image = CvMat.load(search_image.filename)

      result = s_image.match_template(t_image, :sqdiff_normed)

      point = result.min_max_loc[2]
      if point.x > 0 && point.y > 0
        self.match_result = [point.x, point.y]
      end
      return match_result
    end

end
