require 'plist'

module Coloration

  module Readers

    module TextMateThemeReader

      class InvalidThemeError < RuntimeError; end

      def parse_input
        begin
          tm_theme = Plist.parse_xml(input.gsub("ustring", "string"))
        rescue
          raise InvalidThemeError
        end
        raise InvalidThemeError if tm_theme.nil?
        self.name = tm_theme["name"]
        settings = tm_theme["settings"]

        self.ui = settings.delete_at(0)["settings"]
        bg = Color::RGB.from_html(ui["background"][0..6])
        ui.each do |key, value|
          if value.start_with?("#")
            ui[key] = Color::RGBA.from_html(value, bg)
          end
        end
        ui["background"] = bg

        items = {}
        settings.each do |rule|
          selectors = rule["scope"]
          style = rule["settings"]
          if font_style = style.delete("fontStyle")
            if font_style.include?("bold")
              style[:bold] = true
            end
            if font_style.include?("italic")
              style[:italic] = true
            end
            if font_style.include?("underline")
              style[:underline] = true
            end
          end
          style = Style.new(style, bg)
          unless selectors.blank? || style.blank?
            selectors.split(",").each do |selector|
              items[selector.strip] = style
            end
          end
        end
        self.items = ItemsLookup.new(items)
      end

    end # TextMateThemeReader

  end # Readers

end # Coloration
