require 'paint'

module Apa102Rbpi
  class SpiSimulator
    def initialize(opts = {})
      @opts = opts
    end

    def num_leds
      @opts[:num_leds] || 120
    end

    def begin
      yield self
    end

    def clock(data)
    end

    def write(data)
      header = []
      Apa102::START_FRAME.size.times { header << data.shift }
      pixels = ""
      num_leds.times do
        p = []
        4.times { p << data.shift }
        _intensity, b, g, r = p
        pixels << Paint['•', [r, g, b]]
      end
      print "[#{pixels}]\r"
    end
  end
end
