require 'spec_helper'

describe Apa102Rbpi::Strip do
  let(:red)    {{ hex: 0xFF0000, rgb: [255, 0, 0] }}
  let(:green)  {{ hex: 0x00FF00, rgb: [0, 255, 0] }}
  let(:blue)   {{ hex: 0x0000FF, rgb: [0, 0, 255] }}
  let(:default_brightness) {{ led_frame: [255], value: 31 }}
  let(:test_brightness) {{ led_frame: [234], value: 10 }}
  let(:strip) do
    Apa102Rbpi::Strip.new(3, { brightness: default_brightness[:value] })
  end
  let(:base) { Apa102Rbpi.base }

  describe 'instance variables' do
    it 'should have a num_leds reader' do
      expect(strip.num_leds).to be_a_kind_of Integer
      expect(strip.num_leds).to eq 3
    end

    it 'should not write num_leds' do
      expect{ strip.num_leds = 20 }.to raise_error NoMethodError
    end

    it 'should have a head and tail reader' do
      expect(strip.head).to eq 0
      expect(strip.tail).to eq 2
    end

    it 'should not be able to write head and tail' do
      expect{ strip.head = 20 }.to raise_error NoMethodError
      expect{ strip.tail = 20 }.to raise_error NoMethodError
    end

    it 'should have a mirrors reader' do
      expect(strip.mirrors).to be_a_kind_of Set
      expect(strip.mirrors.length).to eq 0
    end
  end

  describe '#set_pixel' do
    before(:each) do
      strip.clear
    end

    it 'lets each pixel color to be set with an rgb array' do
      strip.set_pixel(0, red[:rgb])
      strip.set_pixel(1, green[:rgb])
      strip.set_pixel(2, blue[:rgb])

      expect(base.led_frames[frame_at_pixel(0)]).to eq default_brightness[:led_frame] + red[:rgb]
      expect(base.led_frames[frame_at_pixel(1)]).to eq default_brightness[:led_frame] + green[:rgb]
      expect(base.led_frames[frame_at_pixel(2)]).to eq default_brightness[:led_frame] + blue[:rgb]
    end

    it 'lets each pixel color to be set with a hexadecimal number' do
      strip.set_pixel(0, red[:hex])
      strip.set_pixel(1, green[:hex])
      strip.set_pixel(2, blue[:hex])

      expect(base.led_frames[frame_at_pixel(0)]).to eq default_brightness[:led_frame] + red[:rgb]
      expect(base.led_frames[frame_at_pixel(1)]).to eq default_brightness[:led_frame] + green[:rgb]
      expect(base.led_frames[frame_at_pixel(2)]).to eq default_brightness[:led_frame] + blue[:rgb]
    end

    it 'lets each pixel be set with a unique brightness' do
      strip.set_pixel(0, red[:rgb], test_brightness[:value])
      expect(base.led_frames[frame_at_pixel(0)]).to eq test_brightness[:led_frame] + red[:rgb]
    end

    context 'reverse mode' do
      before(:each) do
        strip.reverse
      end
      after(:each) do
        # set strip to normal
        strip.reverse
      end

      it 'reverses the indices of the pixels being set' do
        strip.set_pixel(0, red[:rgb], test_brightness[:value])
        expect(base.led_frames[frame_at_pixel(2)]).to eq test_brightness[:led_frame] + red[:rgb]
        expect(base.led_frames[frame_at_pixel(0)]).not_to eq test_brightness[:led_frame] + red[:rgb]
      end
    end

    context 'reversed rgb offsets' do
      before(:each) do
        strip.led_frame_rgb_offsets = {
          red: 3,
          green: 2,
          blue: 1
        }
      end
      after(:each) do
        strip.led_frame_rgb_offsets = base.led_frame_rgb_offsets
      end

      it 'changes which led frames receive pixel color data' do
        strip.set_pixel(0, red[:rgb])
        expect(base.led_frames[frame_at_pixel(0)]).not_to eq test_brightness[:led_frame] + red[:rgb].reverse
      end
    end
  end

  describe '#set_all_pixels' do
    it 'sets all pixels to a single color and brightness' do
      strip.set_all_pixels(red[:rgb], test_brightness[:value])

      expect(base.led_frames[frame_at_pixel(0)]).to eq test_brightness[:led_frame] + red[:rgb]
      expect(base.led_frames[frame_at_pixel(1)]).to eq test_brightness[:led_frame] + red[:rgb]
      expect(base.led_frames[frame_at_pixel(2)]).to eq test_brightness[:led_frame] + red[:rgb]
    end
  end

  describe 'mirroring' do
    let(:entire_strip) { Apa102Rbpi.strip }
    let(:strip1) { Apa102Rbpi::Strip.new([0,2]) }
    let(:strip2) { Apa102Rbpi::Strip.new([3,5]) }
    let(:strip3) { Apa102Rbpi::Strip.new([6,8]) }

    it 'lets mirrored strips have pixels set simultaneously' do
      strip1.mirror(strip2)
      strip2.mirror(strip3)

      strip1.set_pixel(0, red[:rgb])
      expect(base.led_frames[frame_at_pixel(0)]).to eq default_brightness[:led_frame] + red[:rgb]
      expect(base.led_frames[frame_at_pixel(3)]).to eq default_brightness[:led_frame] + red[:rgb]
      expect(base.led_frames[frame_at_pixel(6)]).to eq default_brightness[:led_frame] + red[:rgb]
    end
  end
end

def frame_at_pixel(pixel_idx)
  idx = pixel_idx * 4
  Range.new(idx, idx + 3)
end
