GIT_REVISION = if Rails.env.production? || Rails.env.staging?
                 File.read("#{Rails.root}/REVISION").chomp
               else
                 `cd #{Rails.root}; git rev-parse HEAD`.chomp
               end
