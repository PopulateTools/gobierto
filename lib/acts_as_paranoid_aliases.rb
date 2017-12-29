# frozen_string_literal: true

module ActsAsParanoidAliases
  def self.included(base)
    base.extend(ClassMethods)
    class_eval do
      def archive
        return false if archived?
        update_attribute(:archived_at, Time.current)
      end

      def archived?
        deleted?
      end

      def after_archive
      end
    end
  end

  module ClassMethods
    def with_archived
      with_deleted
    end

    def only_archived
      only_deleted
    end
  end
end
