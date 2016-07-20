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

    def set_pixel(pos, color, brightness = nil)
      hex_color = if color.is_a?(Integer)
                    true
                  elsif color.is_a?(Array)
                    false
                  else
                    raise 'Invalid color'
                  end

      base_strip = base
      if @mirrors.empty?
        set_color_helper(base, pos, color, hex_color, brightness)
      else
        q = [self]
        seen = Set.new([self])
        while(substrip = q.pop)
          substrip.mirrors.each do |mirror|
            unless seen.include?(mirror)
              q.push(mirror)
              seen.add(mirror)
            end
            substrip.set_color_helper(base_strip, pos, color, hex_color, brightness)
          end
        end
      end
    end

    def set_color_helper(base_strip, pos, color, hex_color, brightness)
      led_frame_hdr = ((brightness || @brightness) & 0b00011111) | 0b11100000
      idx = if @reverse
              4 * ((@tail - pos) % base.num_leds)
            else
              4 * ((pos + @head) % base.num_leds)
            end

      if hex_color
        base_strip.led_frames[idx] = led_frame_hdr
        base_strip.led_frames[idx + @led_frame_rgb_offsets[:red]] = (color & 0xFF0000) >> 16
        base_strip.led_frames[idx + @led_frame_rgb_offsets[:green]] = (color & 0x00FF00) >> 8
        base_strip.led_frames[idx + @led_frame_rgb_offsets[:blue]] = (color & 0x0000FF)
      else
        base_strip.led_frames[idx] = led_frame_hdr
        base_strip.led_frames[idx + @led_frame_rgb_offsets[:red]] = color[0]
        base_strip.led_frames[idx + @led_frame_rgb_offsets[:green]] = color[1]
        base_strip.led_frames[idx + @led_frame_rgb_offsets[:blue]] = color[2]
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

    private

    def base
      Apa102Rbpi.base
    end
  end
end
