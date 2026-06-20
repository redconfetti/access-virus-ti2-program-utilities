# frozen_string_literal: true

require "csv"

module VirusTi
  module Output
    module Formatter
      module_function

      def render(selection, groups, format: :text)
        case format
        when :text then render_text(selection, groups)
        when :csv then render_csv(selection, groups)
        when :pdf then render_pdf(selection, groups)
        else
          raise ArgumentError, "unsupported output format: #{format}"
        end
      end

      def render_text(selection, groups)
        lines = []
        lines << selection.label
        lines << "Checksum: #{selection.single.checksum_valid? ? "ok" : "INVALID"}"
        lines << ""

        groups.each do |category, params|
          lines << category
          lines << "-" * category.length
          params.each do |param|
            lines << format(
              "  %-40s  %-24s  (%s)",
              param[:name],
              param[:value],
              param[:panel]
            )
          end
          lines << ""
        end

        lines.join("\n")
      end

      def render_csv(_selection, groups)
        CSV.generate do |csv|
          csv << %w[category panel parameter value hex decimal]
          groups.each do |category, params|
            params.each do |param|
              csv << [category, param[:panel], param[:name], param[:value], param[:hex], param[:raw]]
            end
          end
        end
      end

      def render_pdf(selection, groups)
        require "prawn"
        require "prawn/table"

        Prawn::Fonts::AFM.hide_m17n_warning = true if defined?(Prawn::Fonts::AFM)

        Prawn::Document.new(page_size: "LETTER", margin: 36) do |pdf|
          pdf.text pdf_safe("Access Virus TI2 Program"), size: 16, style: :bold
          pdf.move_down 8
          pdf.text pdf_safe(selection.label), size: 12
          pdf.move_down 4
          pdf.text pdf_safe("Checksum: #{selection.single.checksum_valid? ? "ok" : "INVALID"}"), size: 10
          pdf.move_down 16

          groups.each do |category, params|
            pdf.text pdf_safe(category), size: 12, style: :bold
            pdf.move_down 6

            rows = params.map do |param|
              [pdf_safe(param[:name]), pdf_safe(param[:panel]), pdf_safe(param[:value]), param[:hex], param[:raw].to_s]
            end

            pdf.table(
              [["Parameter", "Panel", "Value", "Hex", "Dec"], *rows],
              width: pdf.bounds.width,
              header: true,
              cell_style: { size: 7, padding: [2, 3, 2, 3] }
            ) do
              row(0).font_style = :bold
            end

            pdf.move_down 12
          end
        end.render
      end

      def pdf_safe(text)
        text.to_s
          .tr("→", "->")
          .encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?")
      end
      private_class_method :pdf_safe

      def write_file(path, content, binary: false)
        mode = binary ? "wb" : "w"
        File.write(path, content, mode: mode)
      end
    end
  end
end
