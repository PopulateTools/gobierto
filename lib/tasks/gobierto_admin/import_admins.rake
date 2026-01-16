# frozen_string_literal: true

namespace :gobierto_admin do
  desc "Import regular admins from a CSV file and assign groups"
  # Expected CSV format:
  # - Email: Column containing the admin's email address.
  # - Name: Column containing the admin's name.
  # - Groups: Column containing comma-separated group names to assign to the admin.
  #
  # Group names must match exactly with groups defined in the site.
  # If a group name is not found in the site, a warning message will be displayed
  # and that group will be skipped for that admin.
  task :import_admins, [:site_domain, :csv_path] => :environment do |_t, args|

    site = Site.find_by(domain: args[:site_domain])

    if site.nil?
      puts "[ERROR] No site found for domain: #{args[:site_domain]}"
      exit -1
    end

    csv_path = args[:csv_path]
    unless File.file?(csv_path)
      puts "[ERROR] No CSV file found: #{csv_path}"
      exit -1
    end

    count = 0
    loaded = 0
    puts "[START] Creating users..."
    CSV.read(csv_path, headers: true).each do |row|
      count += 1
      email = row["Email"]
      name = row["Name"]
      group_names = row["Groups"].split(",").map(&:strip)

      admin_groups = group_names.map do |name|
        group = site.admin_groups.find_by(name:)

        puts "Group \"#{name}\" not found in site #{site.domain}" if group.blank?

        group
      end.compact

      existing_admin = GobiertoAdmin::Admin.find_by(email:)

      if existing_admin.present?
        puts "Skipping already existing admin with email #{email}..."
        next
      end
      admin = GobiertoAdmin::Admin.create(name:, email:)
      admin.sites << site
      admin.admin_groups << admin_groups

      loaded += 1 if admin.persisted?
    end

    puts "[END] Created #{loaded} users of #{count}"
  end
end
