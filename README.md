# Apa102Rbpi
Simple library to drive APA102/Dotstar LEDs using a Raspberry Pi

## Setup
The Pi can communicate directly with a APA102 LED strip through the [SPI bus](https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md). Connect the data and clock inputs on the strip to the MOSI and SCLK pins on the Pi board. Be sure to use a 5V power adapter and a logic level shifter for the APA102 inputs as the Pi only outputs 3.3V. After handling the hardware, you're ready to tackle the fun part!

Add this line to your application's Gemfile:

```ruby
gem 'apa102_rbpi'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install apa102_rbpi
```

## Usage
I recommend playing around in the ruby console when getting started.

Note that you must have root permissions to use SPI! Use:
```
sudo irb
```
or
```
sudo bundle exec pretty_lights.rb
```

Simple blinker:

```ruby
require 'apa102_rbpi'
my_strip = Apa102Rbpi.strip
loop do
  my_strip.set_pixel!(0, 0xffffff)
  sleep 1
  my_strip.set_pixel!(0, 0)
  sleep 1
end
```

## Configuration
```ruby
Apa102Rbpi.configure do |c|
  c.num_leds = 100
  c.led_frame_rgb_offsets = {
    red: 3,
    blue: 2,
    green: 1
  }
  c.brightness = 31
  c.spi_hz = 8000000
  c.simulate = ENV['simulate'] || false
end
```

#### num_leds
Set this to your strip's total leds.

#### led_frame_rgb_offsets
Some strips are manufactured under different specifications such that the red/green/blue data frames are in different positions. If you try to input a [r,g,b] color into your strip and end up seeing [b,g,r], for example, you should pass in:
```
  {red: 3, green: 2, blue: 1}
```

#### brightness
Sets the strip's default brightness a range of 0-31

#### spi_hz
Controls how fast data is sent through the SPI bus. The default should be fine for most.

#### simulate
Set this to `true` if you wish to print your strip to the console rather than to the actual hardware strip. Terminal colors will simulate the strip, allowing you to test out patterns anywhere without needing a PI or a connected LED strip.

## Multi-strip usage
The Pi only has a single SPI bus, so it can technically only communicate with a single, contiguous strip. However you can link multiple strips in a chain using [connectors](http://www.ebay.com/itm/10pcs-10mm-4-Pin-two-Connector-with-Cable-For-SMD-LED-5050-RGB-Strip-Light-/181896959852). To ease development with multiple strips, this library offers a few convenience methods for addressing these. See the example below:
```ruby
# Assume 2 connected strips parallel to each other:
# [0,  1,  2,  3,  4,  5,  6,  7,  8,  9] ====\
# [19, 18, 17, 16, 15, 14, 13, 12, 11, 10] ===/

Apa102Rbpi.configure do |c|
  c.num_leds = 20
end

entire_strip = Apa102Rbpi.strip
top_strip = Apa102Rbpi::Strip.new([0,9])
bottom_strip = Apa102Rbpi::Strip.new([10,19],
  {
    # lets you set different offsets if your connected strips have different specs
    led_frame_rgb_offsets: {red: 3, green: 1, blue: 2},
    brightness: 10
  })

# sets pixel 10 red, because the 0th pixel of bottom_strip is at idx 10
bottom_strip.set_pixel!(0, 0xff0000)
# sets that same pixel blue
entire_strip.set_pixel!(10, 0x0000ff)

# sets both the top and bottom strip to display the same content
top_strip.mirror(bottom_strip)
top_strip.clear!
top_strip.set_pixel!(2, 0x00ff00)
# at this point, both pixel 2 and 12 are lit

top_strip.clear!
# reverses the indices of the bottom strip only
bottom_strip.reverse
top_strip.set_pixel!(2, 0x00ff00)
# at this point, pixel 2 and 17 are lit.
```


## Contributing

1. Fork it ( https://github.com/matl33t/apa102_rbpi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
