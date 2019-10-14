require 'RMagick'; include Magick
require 'benchmark'

require_relative('image_matcher_strategies')

# ImageMatcher performs a match between two images.
# * search_image: the "haystack" to search inside
# * template_image: the "needle" for which we are searching
# You also must provide the :strategy to use for matching.
class ImageMatcher

  attr_reader :search_image, :template_image
  attr_reader :match_x, :match_y, :benchmark
  attr_reader :search_cols, :search_rows
  attr_accessor :strategy, :verbose, :highlight_match, :fuzz
  
  @@strategies = {}
  
  include ImageMatcherStrategies
  
  def initialize(options={})
    search_image = options[:search_image]
    template_image = options[:template_image]
    @strategy = options[:strategy]
    @verbose = options[:verbose] === false ? false : true
    @highlight_match = options[:verbose] || false
    @fuzz = options[:fuzz] || 0.0
  end
  
  # Takes a path to the search image and reads in the image 
  # data using ImageMagic.
  # Also sets the number of columns and rows to search to the 
  # total number of columns and rows in the search image.
  def search_image=(filepath)
    @search_image = read_image(filepath)
    @search_cols = search_image.columns
    @search_rows = search_image.rows
    return search_image
  end
  
  # Takes a path to the template image and reads in the image 
  # data using ImageMagic.
  def template_image=(filepath)
    @template_image = read_image(filepath)
  end
  
  # Returns true if matching coordinates have been found, 
  # false otherwise.
  def has_match?
    !match_x.nil? && !match_y.nil?
  end
  
  # Returns the upper-left coordinates of a match as an array [X, Y]
  def match_result
    [match_x, match_y]
  end
  
  # Clears any previous match results
  def clear!
    @match_x = nil
    @match_y = nil
  end
  
  # Perform a match on the current configuration
  # Uses Benchmark to record the time ellapsed while matching.
  # Returns true if a match was found, false otherwise.
  def match!
    clear!
    tighten_search_area
    @benchmark = Benchmark.measure do
      send(strategy_method)
    end
    save_match_file if highlight_match
    return has_match?
  end
  
  private

    # Use ImageMagick to read in the image file
    def read_image(filename)
      if filename
        image = Magick::Image.read(filename).first
        return image
      end
    end

    # Shrinks the area that needs to be searched.
    # We don't need to search full search image. Once the 
    # remaining rows are less than the template image has, 
    # we can give up. Template wouldn't fit in the remaining rows.
    def tighten_search_area
      @search_cols = search_image.columns - template_image.columns
      @search_rows = search_image.rows - template_image.rows
    end
    
    # Some ImageMagick functions will not let you pass in a 
    # fuzz value, instead it gets picked up from the fuzz value 
    # of the image object.
    def add_fuzz_to_images
      if fuzz
        # We must set fuzz on images using the format "40%"
        # where fcmp uses the format "0.4"
        fuzz_as_percent = "#{fuzz.round(2)*100}%"
        puts "Setting fuzz at #{fuzz_as_percent}" if @verbose
        search_image.fuzz = fuzz_as_percent
        template_image.fuzz = fuzz_as_percent
      end
    end
    
    # Use @strategy (a string) to retrieve the method name of the 
    # strategy (a symbol) from the list in @@strategies.
    def strategy_method
      if @@strategies.size == 0
        puts "No match strategies defined."
        exit
      end
      strategy_method = @@strategies[strategy]
      raise "Invalid match strategy" if strategy_method.nil?
      return strategy_method
    end
    
    # Sets match values for @match_x and @match_y when an array 
    # is passed in as an argument.
    def match_result=(array)
      if array && array.is_a?(Array)
        @match_x, @match_y = array
      end
    end

    # Save a copy of the search_image with the match area
    # highlighted.
    def save_match_file
      if match_x && match_y
        end_x = match_x + template_image.columns
        end_y = match_y + template_image.rows

        area = Magick::Draw.new
        area.fill('none')
        area.stroke('red')
        area.stroke_width(3)
        area.rectangle(match_x, match_y, end_x, end_y)
        area.draw(search_image)
        search_image.write(matchfile)
      end
    end

    # Determines the file name for the matchfile (see 
    # #save_match_file).
    # Uses the search image filename with "_match" appended.
    # Saves matchfile in same directory location as the search_image.
    def matchfile
      if search_image
        name_parts = search_image.filename.split('.')
        ext = name_parts.pop
        name = name_parts.join('.')
        return "#{name}_match.#{ext}"
      else
        return "no_search_image.png"
      end
    end
  
end
