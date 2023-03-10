# frozen_string_literal: true

module Frame
  module File
    BEGIN_COMMENT = '# BEGIN MANAGED BY https://github.com/th7/frame'
    END_COMMENT = '# END MANAGED BY https://github.com/th7/frame'

    class << self
      def readlines(path)
        if ::File.exist?(path)
          ::File.readlines(path).map(&:chomp)
        else
          []
        end
      end

      def combine(path, intended_lines)
        existing_lines = readlines(path)
        if existing_lines.empty?
          new_frame_section(intended_lines)
        else
          ensure_trailing_empty(before_lines(existing_lines)) + \
            ensure_trailing_empty(new_frame_section(intended_lines)) + \
            after_lines(existing_lines)
        end
      end

      private

      def ensure_trailing_empty(lines)
        if lines.empty? || lines.last == ''
          lines
        else
          lines + ['']
        end
      end

      def new_frame_section(intended_lines)
        if intended_lines.empty?
          []
        else
          [BEGIN_COMMENT] + \
            intended_lines + \
            [END_COMMENT]
        end
      end

      def before_lines(existing_lines)
        existing_lines.take_while { |line| !line.start_with?(BEGIN_COMMENT) }
      end

      def after_lines(existing_lines)
        end_index = existing_lines.find_index { |line| line.start_with?(END_COMMENT) }
        if end_index
          existing_lines - existing_lines.take(end_index + 1)
        else
          []
        end
      end
    end
  end
end
