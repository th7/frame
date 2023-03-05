# frozen_string_literal: true

require 'frame/slideshow'

RSpec.describe Frame::Slideshow do
  describe '.generate' do
    subject { described_class.generate }

    let(:slideshow) { 'fake slideshow' }

    before do
      allow(Frame::Config).to receive(:slideshow).and_return(slideshow)
    end

    it { is_expected.to eq("#!/usr/bin/env sh\n# MANAGED BY https://github.com/th7/frame\nfake slideshow") }
  end
end
