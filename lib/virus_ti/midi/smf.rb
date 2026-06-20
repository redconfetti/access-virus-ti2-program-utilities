# frozen_string_literal: true

module VirusTi
  module MIDI
    module SMF
      module_function

      def read_vlq(data, offset)
        value = 0
        while offset < data.bytesize
          byte = data.getbyte(offset)
          offset += 1
          value = (value << 7) | (byte & 0x7F)
          break if (byte & 0x80).zero?
        end
        [value, offset]
      end

      def parse(data)
        data = data.b
        raise ArgumentError, "not a Standard MIDI File" unless data.byteslice(0, 4) == "MThd"

        header_length = read_uint32(data, 4)
        offset = 8 + header_length
        sysex_events = []

        while offset + 8 <= data.bytesize && data.byteslice(offset, 4) == "MTrk"
          track_length = read_uint32(data, offset + 4)
          track_start = offset + 8
          track_end = [track_start + track_length, data.bytesize].min
          sysex_events.concat(parse_track(data, track_start, track_end))
          offset = track_start + track_length
        end

        sysex_events
      end

      def parse_track(data, start, track_end)
        events = []
        offset = start
        running_status = nil

        while offset < track_end
          _delta, offset = read_vlq(data, offset)
          status = data.getbyte(offset)

          if status < 0x80
            raise ArgumentError, "missing status byte with no running status" unless running_status

            status = running_status
          else
            offset += 1
            running_status = status if status < 0xF0
          end

          case status
          when 0xF0
            length, offset = read_vlq(data, offset)
            payload = data.byteslice(offset, length)
            offset += length
            events << build_sysex(payload)
          when 0xF7
            length, offset = read_vlq(data, offset)
            offset += length
          when 0xFF
            meta_type = data.getbyte(offset)
            offset += 1
            length, offset = read_vlq(data, offset)
            offset += length
            running_status = nil if meta_type == 0x2F
          when 0xF2
            offset += 2
          when 0xF1, 0xF3
            offset += 1
          when 0xF6, 0xF8, 0xFA, 0xFB, 0xFC, 0xFE
            nil
          else
            param_count = channel_message_param_count(status)
            offset += param_count
          end
        end

        events
      end

      def build_sysex(payload)
        message = +"#{Sysex::START_BYTE.chr}#{payload}"
        message << Sysex::END_BYTE.chr unless message.getbyte(-1) == Sysex::END_BYTE
        message
      end

      def read_uint32(data, offset)
        data.byteslice(offset, 4).unpack1("N")
      end

      def channel_message_param_count(status)
        case status & 0xF0
        when 0xC0, 0xD0 then 1
        else 2
        end
      end
    end
  end
end
