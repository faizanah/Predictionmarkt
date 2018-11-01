namespace :favicon do
  desc "Generate various versions of favicon"
  task :generate do
    FaviconMaker.generate do
      setup do
        template_dir  File.join(Rails.root, 'app', 'assets', 'images', 'logos')
        output_dir    File.join(Rails.root, 'public', 'favicons')
      end

      # https://github.com/audreyr/favicon-cheat-sheet
      png_sizes = %w[57 144 152 196]

      from "square-favicon.png" do
        # needed for mstile, apple touch, android, etc
        png_sizes.each do |s|
          icon "square-#{s}.png", size: "#{s}x#{s}"
        end
      end

      from "round-favicon.png" do
        icon "favicon.ico", size: "64x64,48x48,32x32,24x24,16x16"

        png_sizes.each do |s|
          icon "round-#{s}.png", size: "#{s}x#{s}"
        end
      end

      each_icon { |filepath| puts filepath }
    end
  end
end
