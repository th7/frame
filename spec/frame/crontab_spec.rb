# frozen_string_literal: true

require 'frame/crontab'

RSpec.describe Frame::Crontab do
  describe '.generate' do
    subject { described_class.generate }

    let(:existing_lines) { %w[existing lines] }
    let(:crontab) { 'fake crontab' }

    before do
      allow(Frame::Config).to receive(:crontab).and_return(crontab)
      allow(Frame::File).to receive(:combine).with('/dev/stdin', [crontab]).and_return(%w[fake result])
    end

    it { is_expected.to eq("fake\nresult") }
  end
end
