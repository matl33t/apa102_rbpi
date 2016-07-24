require 'apa102_rbpi'

RSpec.configure do |config|
  config.before do
    Apa102Rbpi.clear_config!
    Apa102Rbpi.configure do |c|
      c.num_leds = 100
      c.simulate = true
      c.led_frame_rgb_offsets = {
        red: 1,
        green: 2,
        blue: 3
      }
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
