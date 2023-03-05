# frozen_string_literal: true

require 'json'
require 'yaml'

module Frame
  module Config
    class << self
      def crontab
        "#{config[:schedule][:off_cron]} rtcwake -m off -s #{config[:schedule][:on_seconds_later]}"
      end

      def fstab
        "//#{path} /mnt/#{path} cifs username=root,password= 0 0"
      end

      def slideshow
        'feh --auto-rotate --hide-pointer --borderless ' \
          '--quiet --slideshow-delay 7 --reload 60 --image-bg black ' \
          "--fullscreen --auto-zoom --randomize --recursive /mnt/#{path}"
      end

      def load
        JSON.parse(JSON.generate(YAML.load(::File.read('frame.yml'))), symbolize_names: true)
      end

      private

      def path
        ::File.join(config.dig(:source, :smb_server), config.dig(:source, :smb_path))
      end

      def config
        @config ||= load
      end
    end
  end
end
