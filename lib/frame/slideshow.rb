# frozen_string_literal: true

require 'frame/config'

module Frame
  module Slideshow
    class << self
      def generate
        "#!/usr/bin/env sh\n# MANAGED BY https://github.com/th7/frame\n#{Frame::Config.slideshow}"
      end
    end
  end
end
