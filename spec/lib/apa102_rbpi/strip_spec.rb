# spec/lib/apa102_rbpi/strip_spec.rb

describe 'Strip' do

  before(:all) do
    Apa102Rbpi.configure do |config|
      config.num_leds = 6
      config.simulate = true
    end
  end

  let(:strip) { Apa102Rbpi.strip }

  it 'should be an instance of a strip' do
    expect(strip.class).to eq Apa102Rbpi::Strip
  end

  describe 'instance variables' do
    it 'should have a num_leds reader' do
      expect(strip.num_leds).to be_a_kind_of Integer
      expect(strip.num_leds).to eq 6
    end

    it 'should not write num_leds' do
      expect{ strip.num_leds = 20 }.to raise_error NoMethodError
    end

    it 'should have a head and tail reader' do
      expect(strip.head).to eq 0
      expect(strip.tail).to eq 5
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

  describe 'pixel setting' do
    before(:each) do
      strip.clear
    end

    it 'should be able to set each pixel with an rgb array' do
      (0..5).each do |n|
        strip.set_pixel(n, [n,n,n])
      end

      expect(Apa102Rbpi.base.led_frames).to eq [ 255, 0, 0, 0, 255, 1, 1, 1,
                                                 255, 2, 2, 2, 255, 3, 3, 3,
                                                 255, 4, 4, 4, 255, 5, 5, 5 ]
    end

    it 'should be able to pass in a brightness with an array' do
      strip.set_pixel(0, [255,255,255], 10)
      expect(Apa102Rbpi.base.led_frames[0..3]).to eq [234, 255, 255, 255]
    end

    it 'should be able to set each pixel with hex' do
      (0..5).each do |n|
        strip.set_pixel(n, 0x4d4dff)
      end

      expect(Apa102Rbpi.base.led_frames).to eq [ 255, 255, 77, 77, 255, 255, 77, 77,
                                                 255, 255, 77, 77, 255, 255, 77, 77,
                                                 255, 255, 77, 77, 255, 255, 77, 77 ]
    end

    it 'should be able to set a brightness with hex' do
      strip.set_pixel(0, 0x4d4dff, 10)
      expect(Apa102Rbpi.base.led_frames[0..3]).to eq [234, 255, 77, 77]
    end

    describe 'set all pixels' do
      it 'should be able to set all the pixels at once' do
        strip.set_all_pixels([10,10,10], 10)

        expect(Apa102Rbpi.base.led_frames).to eq [ 234, 10, 10, 10, 234, 10, 10, 10,
                                                   234, 10, 10, 10, 234, 10, 10, 10,
                                                   234, 10, 10, 10, 234, 10, 10, 10 ]
      end
    end

    describe 'reversing' do
      after(:each) do
        strip.reverse
      end

      it 'should know whether it is reversed' do
        expect(strip.reversed?).to eq false
        strip.reverse
        expect(strip.reversed?).to eq true
      end

      it 'should be able to set a reversed pixel' do
        strip.reverse
        strip.set_pixel(0, [255,255,255])
        expect(Apa102Rbpi.base.led_frames).to eq [ 255, 0, 0, 0, 255, 0, 0, 0,
                                                   255, 0, 0, 0, 255, 0, 0, 0,
                                                   255, 0, 0, 0, 255, 255, 255, 255]
      end
    end

    describe 'altering the rbg array' do
      after(:each) do
        strip.led_frame_rgb_offsets = {red: 3, green: 2, blue: 1}
      end

      it 'should be able to read and alter the rgb array' do
        expect(strip.led_frame_rgb_offsets).to be_a_kind_of Hash
        expect(strip.led_frame_rgb_offsets).to eq({red: 3, green: 2, blue: 1})

        strip.led_frame_rgb_offsets = {red: 3, green: 1, blue: 2}
        expect(strip.led_frame_rgb_offsets).to eq({red: 3, green: 1, blue: 2})
      end

      it 'should set pixels correctly when the array is altered' do
        strip.led_frame_rgb_offsets = {red: 3, green: 1, blue: 2}
        strip.set_pixel(0, [10,100,255])
        expect(Apa102Rbpi.base.led_frames[0..3]).to eq [255, 100, 255, 10]
      end
    end
  end

  describe 'mirroring' do
    let(:entire_strip) { Apa102Rbpi.strip }
    let(:top_strip) { Apa102Rbpi::Strip.new([0,2]) }
    let(:bottom_strip) { Apa102Rbpi::Strip.new([3,5]) }

    it 'should be able to create a mirror out of multiple strips' do
      entire_strip.clear!
      top_strip.mirror(bottom_strip)
      top_strip.set_pixel(2, 0xffff00)

      expect(top_strip.mirrors.length).to eq 1
      expect(top_strip.mirrors.first).to eq bottom_strip

      expect(Apa102Rbpi.base.led_frames).to eq [255, 0, 0, 0, 255, 0, 0, 0,
                                                255, 0, 255, 255, 255, 0, 0, 0,
                                                255, 0, 0, 0, 255, 0, 255, 255 ]
    end
  end
end
