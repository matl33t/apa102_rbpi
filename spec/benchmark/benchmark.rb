require 'apa102_rbpi'
require 'benchmark-perf'

include Apa102Rbpi

Apa102Rbpi.configure do |c|
  c.num_leds = 500
  c.simulate = true
end
strip = Apa102Rbpi.strip

bench = Benchmark::Perf::ExecutionTime.new

def rainbow(strip)
  (0..255).each do |c|
    strip.num_leds.times do |l|
      strip.set_pixel(l, color_wheel(c))
    end
  end
end


mean, stddev = bench.run { rainbow(strip) }

puts "Mean running time: #{mean}"
puts "Standard Deviation: #{stddev}"
