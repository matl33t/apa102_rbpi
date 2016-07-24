module Apa102Rbpi
  class Apa102

    attr_accessor :brightness, :spi_hz, :led_frame_rgb_offsets, :led_frames
    attr_reader :num_leds, :interface, :start_frame, :end_frame, :simulate

    def initialize
      @num_leds = 1

      # default brightness, must be within 0-31
      @brightness = 31

      # some strips may have different led frame specs
      # set offsets if using a non-default strip
      # offset:    0      1    2    3
      # frame = [header|blue|green|red],
      @led_frame_rgb_offsets = {
        red: 3,
        green: 2,
        blue: 1
       }
      @spi_hz = 8000000
      @simulate = false

      @interface = PiPiper::Spi
      @start_frame = [0x00] * 4
      @end_frame = calculate_end_frame


      @led_frames = []
      @substrips = {}
      @mirrors = {}
    end

    def simulate=(bool)
      @simulate = bool
      if @simulate
        @interface = ::Apa102Rbpi::SpiSimulator
      else
        @interface = PiPiper::Spi
      end
    end

    def num_leds=(num)
      @num_leds = num
      @end_frame = calculate_end_frame
    end

    def calculate_end_frame
      [0x00] * (@num_leds / 2.0).ceil
    end

    def show!
      interface.begin do |s|
        s.clock(@spi_hz)
        s.write(@start_frame + @led_frames + @end_frame)
      end
    end

    def print
      ::Apa102Rbpi::SpiSimulator.display(@led_frames)
    end
  end
end

