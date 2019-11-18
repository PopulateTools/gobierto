namespace :dev do

  # bin/rails dev:load_data[staging]
  # bin/rails dev:load_data[production]
  desc "Import data from another evironment"
  task :load_data, [:src_environment] => :environment do |_t, args|
    src_environment = ActiveSupport::StringInquirer.new(args.src_environment)

    raise "Can't run this task in the #{Rails.env} environment" if Rails.env.staging? || Rails.env.production?
    raise "Invalid source environment: #{src_environment}" unless src_environment.staging? || src_environment.production?
    raise "DEV_DIR and DUMPS_DIR environment variables must be defined" if ENV["DEV_DIR"].blank? || ENV["DUMPS_DIR"].blank?

    DEV_DIR = ENV["DEV_DIR"]
    LOCAL_DUMP_DIR = "#{ENV["DUMPS_DIR"]}/gobierto"

    FileUtils.mkdir_p(LOCAL_DUMP_DIR)

    src_host = ENV.fetch("#{src_environment.upcase}_DB_HOST")
    src_host_user = ENV.fetch("#{src_environment.upcase}_DB_HOST_USER")
    src_app_name = ENV.fetch("#{src_environment.upcase}_APP_NAME")
    dump_name = "gobierto_#{src_environment}.sql.gz"
    remote_dump_path = "/home/#{src_host_user}/#{dump_name}"
    local_dump_path = "#{LOCAL_DUMP_DIR}/#{dump_name}"

    puts "Generating remote dump #{dump_name} in #{src_host}..."
    system("ssh #{src_host} 'pg_dump -U postgres -Fc -f #{remote_dump_path} -Z 9 #{src_app_name}'")

    puts "Downloading remote dump from #{src_host}..."
    system("scp #{src_host}:#{remote_dump_path} #{local_dump_path}")

    puts "Removing local DB..."
    system("cd #{DEV_DIR}/gobierto && bundle install && yarn install")
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke

    puts "Restoring dump..."
    system("pg_restore -d gobierto_development --no-owner #{local_dump_path}")

    puts "Migrating local DB..."
    Rake::Task["db:migrate"].invoke

    puts "Removing downloaded dump..."
    File.delete(local_dump_path)

    puts "Removing remote dump..."
    system("ssh #{src_host} 'rm #{remote_dump_path}'")

    Rake::Task["dev:convert_domains"].invoke
  end

  # bin/rails dev:convert_domains
  desc "Convert domains for development environment"
  task convert_domains: :environment do
    raise "Can't run this task in the #{Rails.env} environment" if Rails.env.staging? || Rails.env.production?

    puts "Converting domains..."

    Site.all.each do |site|
      original_domain = site.domain

      if original_domain.include?("gobify")
        site.domain = original_domain.gsub("gobify", "gobierto").gsub("net", "test")
      else
        site.domain = original_domain.split(".").first + ".gobierto.test"
      end

      puts "#{original_domain} => #{site.domain}"
      site.save
    end
  end

end
