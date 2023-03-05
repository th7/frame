# frozen_string_literal: true

require 'frame/config'
require 'frame/file'

module Frame
  module Fstab
    class << self
      def generate
        Frame::File.combine('/etc/fstab', [Frame::Config.fstab]).join("\n")
      end
    end
  end
end
