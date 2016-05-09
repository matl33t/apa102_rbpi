require 'pi_piper'
require 'apa102_rbpi/spi_simulator'

module Apa102Rbpi
  def self.simulate(n = 120)
    Apa102.new(n, simulate: true)
  end

  class Apa102
    include PiPiper

    START_FRAME = [0x00] * 4

    attr_accessor :brightness
    attr_reader :num_leds, :spi_hz, :led_frame_rgb_offsets, :interface

    def initialize(num_leds, opts = {})
      @num_leds   = num_leds          || 1

      # default brightness, must be within 0-31
      @brightness = opts[:brightness] || 31
      @spi_hz     = opts[:spi_hz]     || 8000000

      # some strips may have different led frame specs
      # set offsets if using a non-default strip
      # offset:    0      1    2    3
      # frame = [header|blue|green|red],
      @led_frame_rgb_offsets  = opts[:led_frame_rgb_offsets] || { red: 3, green: 2, blue: 1 }

      @led_frames = []
      @end_frame = [0x00] * (@num_leds / 2.0).ceil

      @interface = opts[:simulate] ? Apa102Rbpi::SpiSimulator.new(num_leds: num_leds) : Spi

      clear!
    end

    # Sets color of a single pixel at specified position in the strip
    # accepts an array of [r,g,b] values or a single 3 byte value
    def set_pixel(pos, color, brightness = @brightness)
      idx = pos * 4
      if color.is_a?(Integer)
        @led_frames[idx] = led_frame_hdr(brightness)
        @led_frames[idx + @led_frame_rgb_offsets[:red]] = (color & 0xFF0000) >> 16
        @led_frames[idx + @led_frame_rgb_offsets[:green]] = (color & 0x00FF00) >> 8
        @led_frames[idx + @led_frame_rgb_offsets[:blue]] = (color & 0x0000FF)
      elsif color.is_a?(Array)
        @led_frames[idx] = led_frame_hdr(brightness)
        @led_frames[idx + @led_frame_rgb_offsets[:red]] = color[0]
        @led_frames[idx + @led_frame_rgb_offsets[:green]] = color[1]
        @led_frames[idx + @led_frame_rgb_offsets[:blue]] = color[2]
      else
        raise 'Invalid color'
      end
    end

    def set_pixel!(pos, color, brightness = @brightness)
      set_pixel(pos, color, brightness)
      show!
    end

    def clear!
      @num_leds.times do |l|
        set_pixel(l, 0)
      end
      show!
    end

    # Writes out the led frames to the strip
    def show!
      interface.begin do |s|
        s.clock(@spi_hz)
        s.write(START_FRAME + @led_frames + @end_frame)
      end
    end

    private

    # First 3 bits high, then 5 bits for brightness
    def led_frame_hdr(brightness)
      (brightness & 0b00011111) | 0b11100000
    end
  end
end
