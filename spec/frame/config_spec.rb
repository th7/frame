# frozen_string_literal: true

require 'frame/config'

RSpec.describe Frame::Config do
  before { described_class.instance_variable_set(:@config, nil) }

  describe '.load' do
    subject { described_class.load }

    let(:file_contents) { "some:\n yaml" }

    before do
      allow(File).to receive(:read).with('frame.yml').and_return(file_contents)
    end

    it { is_expected.to eq(some: 'yaml') }
  end

  describe '.crontab' do
    subject { described_class.crontab }

    let(:config) { { schedule: { off_cron: '1 2 3 4 5', on_seconds_later: 12_345 } } }

    before do
      allow(described_class).to receive(:load).and_return(config)
    end

    it { is_expected.to eq('1 2 3 4 5 rtcwake -m off -s 12345') }
  end

  describe '.fstab_mount_path' do
    subject { described_class.fstab_mount_path }

    let(:config) { { source: { smb_server: 'smb.local', smb_share: 'share' } } }

    before do
      allow(described_class).to receive(:load).and_return(config)
    end

    it { is_expected.to eq('/mnt/smb.local/share') }
  end

  describe '.fstab' do
    subject { described_class.fstab }

    let(:config) { { source: { smb_server: 'smb.local', smb_share: 'share' } } }

    before do
      allow(described_class).to receive(:load).and_return(config)
    end

    it 'creates the dir and configures fstab' do
      expect(subject).to eq('//smb.local/share /mnt/smb.local/share cifs username=root,password= 0 0')
    end
  end

  describe '.slideshow' do
    subject { described_class.slideshow }

    let(:config) { { source: { smb_server: 'smb.local', smb_share: 'share', path: 'some/path' } } }
    let(:expected) do
      'feh --auto-rotate --hide-pointer --borderless ' \
        '--quiet --slideshow-delay 12 --reload 60 --image-bg black ' \
        '--fullscreen --auto-zoom --randomize --recursive /mnt/smb.local/share/some/path'
    end

    before do
      allow(described_class).to receive(:load).and_return(config)
    end

    it { is_expected.to eq(expected) }
  end

  describe '.autostart' do
    subject { described_class.autostart }

    let(:expected) do
      <<~TEXT
        [Desktop Entry]
        Type=Application
        Exec=/home/fake-user/frame-slideshow &>> /home/fake-user/frame-slideshow.log
        Hidden=false
        NoDisplay=false
        X-GNOME-Autostart-enabled=true
        Name[en_US]=Frame Slideshow
        Name=Frame Slideshow
        Comment[en_US]=Managed by https://github.com/th7/frame
        Comment=Managed by https://github.com/th7/frame
      TEXT
    end

    before do
      allow(ENV).to receive(:fetch).with('USER').and_return('fake-user')
      # allow(described_class).to receive(:load).and_return(config)
    end

    it { is_expected.to eq(expected) }
  end
end
