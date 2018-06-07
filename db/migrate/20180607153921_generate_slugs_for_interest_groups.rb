# frozen_string_literal: true

class GenerateSlugsForInterestGroups < ActiveRecord::Migration[5.2]

  def up
    ::GobiertoPeople::InterestGroup.all.each(&:save!)
  end

  def down
    ::GobiertoPeople::InterestGroup.update_attribute(:slug, nil)
  end

end
