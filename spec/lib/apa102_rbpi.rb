require 'spec_helper'

describe Apa102Rbpi do
  describe '#configure' do
    it 'clears out any existing configuration before applying new settings' do
      Apa102Rbpi.configure do |config|
        config.num_leds = 20
        config.brightness = 20
        config.simulate = true
      end

      expect(Apa102Rbpi.base.num_leds).to eq 20
      expect(Apa102Rbpi.base.brightness).to eq 20

      Apa102Rbpi.configure do |config|
        config.brightness = 30
        config.simulate = true
      end

      expect(Apa102Rbpi.base.num_leds).to eq 1
      expect(Apa102Rbpi.base.brightness).to eq 30

    end

    it 'allows a block to be passed in to set configurations' do
      Apa102Rbpi.configure do |config|
        config.simulate = true
        config.num_leds = 17
        config.brightness = 12
        config.spi_hz = 400000
        config.led_frame_rgb_offsets = {red: 1, green: 2, blue: 3}
      end

      expect(Apa102Rbpi.base.num_leds).to eq 17
      expect(Apa102Rbpi.base.simulate).to eq true
      expect(Apa102Rbpi.base.brightness).to eq 12
      expect(Apa102Rbpi.base.spi_hz).to eq 400000
      expect(Apa102Rbpi.base.led_frame_rgb_offsets).to eq({red: 1, green: 2, blue: 3})
    end
  end

  describe '#clear_config!' do
    it 'creates a new base and strip object with default config' do
      Apa102Rbpi.configure do |config|
        config.num_leds = 20
        config.simulate = true
      end

      base_id = Apa102Rbpi.base.object_id
      strip_id = Apa102Rbpi.strip.object_id

      expect(Apa102Rbpi.base.num_leds).to eq 20

      Apa102Rbpi.clear_config!

      expect(Apa102Rbpi.base.object_id).not_to eq(base_id)
      expect(Apa102Rbpi.strip.object_id).not_to eq(strip_id)
      expect(Apa102Rbpi.base.num_leds).to eq 1
    end
  end
end
