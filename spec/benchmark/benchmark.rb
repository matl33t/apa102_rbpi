require 'apa102_rbpi'
require 'benchmark-perf'

include Apa102Rbpi

Apa102Rbpi.configure do |c|
  c.num_leds = 500
  c.simulate = true
end
single_strip = Apa102Rbpi.strip

mirror_strip = Apa102Rbpi::Strip.new([0, 99])
strip2 = Apa102Rbpi::Strip.new([100, 199])
strip3 = Apa102Rbpi::Strip.new([200, 299])
strip4 = Apa102Rbpi::Strip.new([300, 399])
strip5 = Apa102Rbpi::Strip.new([400, 499])
mirror_strip.mirror(strip2)
strip2.mirror(strip3)
strip3.mirror(strip4)
strip4.mirror(strip5)

bench = Benchmark::Perf::ExecutionTime.new

def rainbow(strip)
  (0..255).each do |c|
    color = color_wheel(c)
    strip.num_leds.times do |l|
      strip.set_pixel(l, color)
    end
  end
end

puts 'Running benchmark for single strip...'
mean, stddev = bench.run { rainbow(single_strip) }
puts "Mean running time: #{mean}"
puts "Standard Deviation: #{stddev}"

puts 'Running benchmark for mirrored strips...'
mean, stddev = bench.run { rainbow(mirror_strip) }
puts "Mean running time: #{mean}"
puts "Standard Deviation: #{stddev}"
