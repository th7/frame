# frozen_string_literal: true

require 'json'
require 'yaml'

module Frame
  module Config
    class << self
      def crontab
        "#{config[:schedule][:off_cron]} rtcwake -m off -s #{config[:schedule][:on_seconds_later]}"
      end

      def fstab_mount_path
        "/mnt/#{smb_path}"
      end

      def fstab
        "//#{smb_path} #{fstab_mount_path} cifs username=root,password= 0 0"
      end

      def slideshow
        'feh --auto-rotate --hide-pointer --borderless ' \
          '--quiet --slideshow-delay 12 --reload 60 --image-bg black ' \
          "--fullscreen --auto-zoom --randomize --recursive /mnt/#{::File.join(smb_path, sub_path)}"
      end

      # path must match in ./frame
      def autostart
        <<~TEXT
          [Desktop Entry]
          Type=Application
          Exec=/home/#{ENV.fetch('USER')}/frame-slideshow &>> /home/#{ENV.fetch('USER')}/frame-slideshow.log
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
          Name[en_US]=Frame Slideshow
          Name=Frame Slideshow
          Comment[en_US]=Managed by https://github.com/th7/frame
          Comment=Managed by https://github.com/th7/frame
        TEXT
      end

      def load
        JSON.parse(JSON.generate(YAML.load(::File.read('frame.yml'))), symbolize_names: true)
      end

      private

      def smb_path
        ::File.join(config.dig(:source, :smb_server), config.dig(:source, :smb_share))
      end

      def sub_path
        config.dig(:source, :path)
      end

      def config
        @config ||= load
      end
    end
  end
end
