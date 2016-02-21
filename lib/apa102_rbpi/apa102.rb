require 'pi_piper'

module Apa102Rbpi
  include PiPiper

  class Apa102
    START_FRAME = [0x00] * 4

    attr_accessor :brightness

    def initialize(opts = {})
      @num_leds   = opts[:num_leds]   || 1
      @brightness = opts[:brightness] || 31
      @spi_hz     = opts[:spi_hz]     || 8000000

      # some strips may have different led frame specs
      # set offsets if using a non-default strip
      # offset:    0      1    2    3
      # frame = [header|blue|green|red],
      @led_frame_blue_offset  = opts[:led_frame_blue_offset]  || 1
      @led_frame_green_offset = opts[:led_frame_green_offset] || 2
      @led_frame_red_offset   = opts[:led_frame_red_offset]   || 3

      @led_frames = []
      @end_frame = [0x00] * (@num_leds / 2.0).ceil

      # reset all pixels to off
      (0..@num_leds).each do |l|
        self.set_pixel_color(l, 0x00)
      end
      self.show!
    end

    # Sets color of a single pixel at specified position in the strip
    # accepts an array of [r,g,b] values or a single 3 byte value
    def set_pixel_color(pos, color)
      idx = pos * 4
      if color.is_a?(Integer)
        @led_frames[idx] = led_frame_hdr
        @led_frames[idx + @led_frame_red_offset] = (color & 0xFF0000) >> 16
        @led_frames[idx + @led_frame_green_offset] = (color & 0x00FF00) >> 8
        @led_frames[idx + @led_frame_blue_offset] = (color & 0x0000FF)
      elsif color.is_a?(Array)
        @led_frames[idx] = led_frame_hdr
        @led_frames[idx + @led_frame_red_offset] = color[0]
        @led_frames[idx + @led_frame_green_offset] = color[1]
        @led_frames[idx + @led_frame_blue_offset] = color[2]
      else
        raise 'Invalid color'
      end
    end

    # Writes out the led frames to the strip
    def show!
      Spi.begin do |s|
        s.clock(@spi_hz)
        s.write(START_FRAME + @led_frames + @end_frame)
      end
    end

    private

    # First 3 bits high, then 5 bits for brightness
    def led_frame_hdr
      (@brightness & 0b00011111) | 0b11100000
    end
  end
end
