# frozen_string_literal: true

require 'frame/fstab'

RSpec.describe Frame::Fstab do
  describe '.generate' do
    subject { described_class.generate }

    let(:fstab) { 'fake fstab' }

    before do
      allow(Frame::Config).to receive(:fstab).and_return(fstab)
      allow(Frame::File).to receive(:combine).with('/etc/fstab', [fstab]).and_return(%w[fake result])
    end

    it { is_expected.to eq("fake\nresult") }
  end
end
