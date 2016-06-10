module Apa102Rbpi
  class Strip

    require 'set'

    attr_reader :mirrors, :head, :tail, :num_leds
    attr_accessor :led_frame_rgb_offsets, :brightness

    def initialize(len = base.num_leds, opts = {})
      if len.is_a?(Array)
        @head = len[0]
        @tail = len[1]
        if @head > @tail
          raise "Beginning of strip can't be a higher index than end"
        end
        @num_leds = (@tail - @head) + 1
      else
        @num_leds = len
        @head = 0
        @tail = @num_leds - 1
      end

      @reverse = false

      @led_frame_rgb_offsets = opts[:led_frame_rgb_offsets] || base.led_frame_rgb_offsets
      @brightness = opts[:brightness] || base.brightness
      @mirrors = Set.new
    end

    def reverse
      @reverse = !@reverse
    end

    def reversed?
      @reverse
    end

    def mirror(strip)
      if strip.num_leds == @num_leds
        @mirrors.add(strip)
        strip.mirrors.add(self)
      else
        raise 'Strips must be of same length to be mirrored!'
      end
    end

    def show!
      base.show!
    end

    def set_pixel(pos, color, brightness = @brightness)
      q = [self]
      seen = Set.new([self])
      frames = base.led_frames
      while(substrip = q.pop)
        substrip.mirrors.each do |mirror|
          unless seen.include?(mirror)
            q.push(mirror)
            seen.add(mirror)
          end
        end

        idx = if substrip.reversed?
                4 * ((substrip.tail - pos) % base.num_leds)
              else
                4 * ((pos + substrip.head) % base.num_leds)
              end

        if color.is_a?(Integer)
          frames[idx] = substrip.led_frame_hdr(brightness)
          frames[idx + substrip.led_frame_rgb_offsets[:red]] = (color & 0xFF0000) >> 16
          frames[idx + substrip.led_frame_rgb_offsets[:green]] = (color & 0x00FF00) >> 8
          frames[idx + substrip.led_frame_rgb_offsets[:blue]] = (color & 0x0000FF)
        elsif color.is_a?(Array)
          frames[idx] = substrip.led_frame_hdr(brightness)
          frames[idx + substrip.led_frame_rgb_offsets[:red]] = color[0]
          frames[idx + substrip.led_frame_rgb_offsets[:green]] = color[1]
          frames[idx + substrip.led_frame_rgb_offsets[:blue]] = color[2]
        else
          raise 'Invalid color'
        end
      end
    end

    def set_pixel!(pos, color, brightness = @brightness)
      set_pixel(pos, color, brightness)
      show!
    end

    def set_all_pixels(color, brightness = @brightness)
      @num_leds.times do |led_idx|
        set_pixel(led_idx, color, brightness)
      end
    end

    def set_all_pixels!(color, brightness = @brightness)
      set_all_pixels(color, brightness)
      show!
    end

    def clear
      @num_leds.times do |led_idx|
        set_pixel(led_idx, 0)
      end
    end

    def clear!
      clear
      show!
    end

    def led_frame_hdr(brightness = @brightness)
      (brightness & 0b00011111) | 0b11100000
    end

    private

    def base
      Apa102Rbpi.base
    end
  end
end
