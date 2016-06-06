require 'spec_helper'

describe Apa102Rbpi do
  describe '#configure' do
    it 'clears out any existing configuration before applying new settings' do

    end

    it 'allows a block to be passed in to set configurations' do
      Apa102Rbpi.configure do |config|
        config.num_leds = 1
      end
    end
  end

  describe '#config' do

  end

  describe '#clear_config!' do

  end
end
