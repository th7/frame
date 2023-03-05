# frozen_string_literal: true

require 'frame/file'

RSpec.describe Frame::File do
  describe '.readlines' do
    subject { described_class.readlines('/some/path') }

    let(:file_exists) { true }

    before do
      allow(File).to receive(:exist?).with('/some/path').and_return(file_exists)
      allow(File).to receive(:readlines).with('/some/path').and_return(%W[fake\n lines\n])
    end

    it { is_expected.to eq(%w[fake lines]) }

    context 'when file does not exist' do
      let(:file_exists) { false }

      it { is_expected.to eq([]) }
    end
  end

  describe '.combine' do
    subject { described_class.combine('/fake/path', intended_lines) }

    let(:intended_lines) { ['line 1', 'line 2'] }
    let(:existing_lines) { [] }
    let(:expected_frame_section) do
      [
        described_class::BEGIN_COMMENT,
        'line 1',
        'line 2',
        described_class::END_COMMENT
      ]
    end

    before do
      allow(described_class).to receive(:readlines).with('/fake/path').and_return(existing_lines)
    end

    it 'surrounds the intended_lines with comments' do
      expect(subject).to eq(expected_frame_section)
    end

    context 'when other lines exist' do
      let(:existing_lines) { ['existing line 1', 'existing line 2'] }

      it 'appends' do
        expect(subject).to eq(existing_lines + [''] + expected_frame_section + [''])
      end
    end

    context 'when pre-existing frame section exists' do
      let(:existing_lines) do
        [
          described_class::BEGIN_COMMENT,
          'replace 1',
          'replace 2',
          described_class::END_COMMENT
        ]
      end

      it 'replaces' do
        expect(subject).to eq(expected_frame_section + [''])
      end
    end

    context 'when no intended lines' do
      let(:intended_lines) { [] }

      it { is_expected.to eq([]) }
    end

    context 'when lines are intermingled' do
      let(:existing_lines) do
        [
          'keep before 1',
          'keep before 2',
          described_class::BEGIN_COMMENT,
          'replace 1',
          'replace 2',
          described_class::END_COMMENT,
          'keep after 1',
          'keep after 2'
        ]
      end
      let(:expected_lines) do
        [
          'keep before 1',
          'keep before 2',
          '',
          described_class::BEGIN_COMMENT,
          'line 1',
          'line 2',
          described_class::END_COMMENT,
          '',
          'keep after 1',
          'keep after 2'
        ]
      end

      it 'replaces only the expected section' do
        expect(subject).to eq(expected_lines)
      end
    end

    context 'when repeating' do
      let(:existing_lines) do
        [
          'keep before 1',
          'keep before 2',
          described_class::BEGIN_COMMENT,
          'replace 1',
          'replace 2',
          described_class::END_COMMENT,
          'keep after 1',
          'keep after 2'
        ]
      end
      let(:expected_lines) do
        [
          'keep before 1',
          'keep before 2',
          '',
          described_class::BEGIN_COMMENT,
          'line 1',
          'line 2',
          described_class::END_COMMENT,
          '',
          'keep after 1',
          'keep after 2'
        ]
      end

      before do
        pass1 = described_class.combine('/fake/path', intended_lines)
        allow(described_class).to receive(:readlines).with('/fake/path').and_return(pass1)
        pass2 = described_class.combine('/fake/path', intended_lines)
        allow(described_class).to receive(:readlines).with('/fake/path').and_return(pass2)
      end

      it 'is idempotent' do
        expect(described_class.combine('/fake/path', intended_lines)).to eq(expected_lines)
      end
    end
  end
end
