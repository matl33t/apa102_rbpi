module Apa102Rbpi
  class Strip
    require 'set'

    attr_reader :head, :tail, :num_leds, :base, :mirrors
    attr_accessor :led_frame_rgb_offsets, :brightness

    def initialize(len = Apa102Rbpi.base.num_leds, opts = {})
      @base = Apa102Rbpi.base
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

      @led_frame_rgb_offsets = opts[:led_frame_rgb_offsets] || @base.led_frame_rgb_offsets
      @brightness = opts[:brightness] || @base.brightness
      @mirrors = Set.new
    end

    def reverse
      @reverse = !@reverse
    end

    def reversed?
      @reverse
    end

    def mirror(other_strip)
      new_mirrors = @mirrors + other_strip.mirrors + Set.new([self, other_strip])
      new_mirrors.each do |m|
        m.mirrors += (new_mirrors - [m])
      end
    end

    def clear_mirrors
      @mirrors.each do |m|
        m.mirrors -= [self]
      end

      @mirrors.clear
    end

    def show!
      @base.show!
    end

    def set_pixel(pos, color, brightness = nil)
      is_hex = if color.is_a?(Integer)
                  true
               elsif color.is_a?(Array)
                 false
               else
                 raise 'Invalid color'
               end

      set_pixel_helper(pos, color, is_hex, brightness || @brightness)
      unless @mirrors.empty?
        @mirrors.each do |strip|
          strip.set_pixel_helper(pos, color, is_hex, brightness || strip.brightness)
        end
      end
    end

    def set_pixel_helper(pos, color, is_hex, brightness)
      led_frame_hdr = (brightness & 0b00011111) | 0b11100000
      idx = if @reverse
              4 * ((@tail - pos) % @base.num_leds)
            else
              4 * ((pos + @head) % @base.num_leds)
            end

      if is_hex
        @base.led_frames[idx] = led_frame_hdr
        @base.led_frames[idx + @led_frame_rgb_offsets[:red]] = (color & 0xFF0000) >> 16
        @base.led_frames[idx + @led_frame_rgb_offsets[:green]] = (color & 0x00FF00) >> 8
        @base.led_frames[idx + @led_frame_rgb_offsets[:blue]] = (color & 0x0000FF)
      else
        @base.led_frames[idx] = led_frame_hdr
        @base.led_frames[idx + @led_frame_rgb_offsets[:red]] = color[0]
        @base.led_frames[idx + @led_frame_rgb_offsets[:green]] = color[1]
        @base.led_frames[idx + @led_frame_rgb_offsets[:blue]] = color[2]
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

    protected

    def mirrors=(m)
      @mirrors = m
    end
  end
end
