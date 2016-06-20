describe 'Utility Functions' do
  let(:klass)  { Class.new { extend Apa102Rbpi } }
  let(:red)    {{ hex: 0xFF0000, rgb: [255, 0, 0] }}
  let(:yellow) {{ hex: 0x817E00, rgb: [129, 126, 0] }}
  let(:green)  {{ hex: 0x00FF00, rgb: [0, 255, 0] }}
  let(:cyan)   {{ hex: 0x00817E, rgb: [0, 129, 126] }}
  let(:blue)   {{ hex: 0x0000FF, rgb: [0, 0, 255] }}
  let(:indigo) {{ hex: 0x7E0081, rgb: [126, 0, 129] }}

  describe '#color_wheel' do
    it 'should convert a 0-255 value to a color hex value' do
      expect(klass.color_wheel(0)).to eq(red[:hex])
      expect(klass.color_wheel(42)).to eq(yellow[:hex])
      expect(klass.color_wheel(85)).to eq(green[:hex])
      expect(klass.color_wheel(127)).to eq(cyan[:hex])
      expect(klass.color_wheel(170)).to eq(blue[:hex])
      expect(klass.color_wheel(212)).to eq(indigo[:hex])
      expect(klass.color_wheel(255)).to eq(red[:hex])
    end
  end

  describe '#rgb_to_hex' do
    it 'should convert RGB to Hex' do
      expect(klass.rgb_to_hex(*red[:rgb])).to eq(red[:hex])
      expect(klass.rgb_to_hex(*yellow[:rgb])).to eq(yellow[:hex])
      expect(klass.rgb_to_hex(*green[:rgb])).to eq(green[:hex])
      expect(klass.rgb_to_hex(*cyan[:rgb])).to eq(cyan[:hex])
      expect(klass.rgb_to_hex(*blue[:rgb])).to eq(blue[:hex])
      expect(klass.rgb_to_hex(*indigo[:rgb])).to eq(indigo[:hex])
    end
  end

  describe '#hex_to_rgb' do
    it 'should convert Hex to RGB' do
      expect(klass.hex_to_rgb(red[:hex])).to eq(red[:rgb])
      expect(klass.hex_to_rgb(yellow[:hex])).to eq(yellow[:rgb])
      expect(klass.hex_to_rgb(green[:hex])).to eq(green[:rgb])
      expect(klass.hex_to_rgb(cyan[:hex])).to eq(cyan[:rgb])
      expect(klass.hex_to_rgb(blue[:hex])).to eq(blue[:rgb])
      expect(klass.hex_to_rgb(indigo[:hex])).to eq(indigo[:rgb])
    end
  end
end
