module PopulateData
  module Gobierto
    module Logging
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def logger
          Logging.logger
        end
      end

      def self.logger
        @logger ||= begin
          logger = Logger.new(STDOUT)
          logger.formatter = proc do |severity, datetime, progname, msg|
            "[PopulateData::Gobierto] #{datetime}: #{msg}\n"
          end

          logger
        end
      end
    end
  end
end
