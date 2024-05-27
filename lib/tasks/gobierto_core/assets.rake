# frozen_string_literal: true

namespace :gobierto_core do
  namespace :assets do
    desc "Exports embeds assets, removing the digest from the filename"
    task export_embeds: :environment do
      file_paths = Dir.glob(Rails.root.join("public", "assets", "embeds*")).select do |embed_path|
        embed_path =~ /embeds-[^.]+\.(js|css)\z/
      end.sort_by{ |p| File.mtime(p) }
      file_paths.each do |file_path|
        new_name = file_path.gsub(/embeds-[^.]+\.(js|css)\z/, "embeds.\\1")
        FileUtils.cp(file_path, new_name)
      end
    end
  end
end
