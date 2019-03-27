# frozen_string_literal: true

#
require_dependency Rails.root.join("lib/publisher")
require_dependency Rails.root.join("app/publishers/base")
Dir.glob("app/publishers/*.rb").each do |publisher_path|
  require_dependency Rails.root.join(publisher_path)
end
