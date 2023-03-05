# frozen_string_literal: true

require 'frame/config'
require 'frame/file'

module Frame
  module Crontab
    class << self
      def generate
        Frame::File.combine('/dev/stdin', [Frame::Config.crontab]).join("\n")
      end

      private

      def try_read(path)
        if ::File.exist?(path)
          ::File.readlines(path)
        else
          []
        end
      end
    end
  end
end
