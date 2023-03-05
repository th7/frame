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

  describe '.fstab' do
    subject { described_class.fstab }

    let(:config) { { source: { smb_server: 'smb.local', smb_path: '/some/path' } } }

    before do
      allow(described_class).to receive(:load).and_return(config)
    end

    it { is_expected.to eq('//smb.local/some/path /mnt/smb.local/some/path cifs username=root,password= 0 0') }
  end

  describe '.slideshow' do
    subject { described_class.slideshow }

    let(:config) { { source: { smb_server: 'smb.local', smb_path: '/some/path' } } }
    let(:expected) do
      'feh --auto-rotate --hide-pointer --borderless ' \
        '--quiet --slideshow-delay 7 --reload 60 --image-bg black ' \
        '--fullscreen --auto-zoom --randomize --recursive /mnt/smb.local/some/path'
    end

    before do
      allow(described_class).to receive(:load).and_return(config)
    end

    it { is_expected.to eq(expected) }
  end
end
