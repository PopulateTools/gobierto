# frozen_string_literal: true

module GobiertoAttachments
  def self.table_name_prefix
    "ga_"
  end

  def self.permitted_attachable_types
    %w(GobiertoCms::Page GobiertoCalendars::Event)
  end
end
