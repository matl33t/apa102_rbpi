require 'paint'

module Apa102Rbpi
  module SpiSimulator
    class << self
      def begin
        yield self
      end

      # Placeholder method, no-op
      def clock(data)
      end

      # Prints a strip in place
      def write(data)
        # strip off header frame bytes
        base.start_frame.size.times { data.shift }
        # strip off end frame byes
        base.end_frame.size.times { data.pop }

        # carriage return at the end lets us update strip display in place
        print "[#{extract_pixels(data)}]\r"
      end

      # Prints a strip on its own line
      def display(led_frames)
        puts "[#{extract_pixels(led_frames)}]"
      end

      def extract_pixels(led_frames)
        pixels = ""
        (led_frames.size / 4).times do |idx|
          idx *= 4
          # frame data is 32 bytes:
          # first byte is brightness (unused)
          # next 3 bytes depend on the frame offsets

          r = led_frames[idx + base.led_frame_rgb_offsets[:red]] || 0
          g = led_frames[idx + base.led_frame_rgb_offsets[:green]] || 0
          b = led_frames[idx + base.led_frame_rgb_offsets[:blue]] || 0
          pixels << Paint['•', [r, g, b]]
        end

        pixels
      end

      def base
        Apa102Rbpi.base
      end
    end
  end
end
