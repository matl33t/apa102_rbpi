require 'pi_piper'
require 'apa102_rbpi/spi_simulator'
require 'apa102_rbpi/strip'
require 'apa102_rbpi/apa102'
require 'apa102_rbpi/utils'
require 'apa102_rbpi/version'

module Apa102Rbpi
  def self.configure
    clear_config!
    yield base
    strip.clear!
  end

  def self.base
    @base ||= Apa102.new
  end

  def self.clear_config!
    @base = nil
    @strip = nil
  end

  def self.strip
    @strip ||= Strip.new
  end
end
