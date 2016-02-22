module Apa102Rbpi
  # Input a 1-byte value to get a color
  # Colors are from r->g->b->r
  def color_wheel(wheel_pos)
    wheel_pos &= 255

    if wheel_pos < 85
      rgb_to_hex(255 - wheel_pos * 3, wheel_pos * 3, 0)
    elsif wheel_pos < 170
      wheel_pos -= 85
      rgb_to_hex(0, 255 - wheel_pos * 3, wheel_pos * 3)
    else
      wheel_pos -= 170
      rgb_to_hex(wheel_pos * 3, 0, 255 - wheel_pos * 3)
    end
  end

  # convert to a 3-byte hex color value
  def rgb_to_hex(red, green, blue)
    (red << 16) + (green << 8) + blue
  end

  # convert 3-byte hex color to [red, green, blue]
  def hex_to_rgb(hex)
    [
      (hex & 0xFF0000) >> 16,
      (hex & 0x00FF00) >> 8,
      (hex & 0x0000FF)
    ]
  end
end
