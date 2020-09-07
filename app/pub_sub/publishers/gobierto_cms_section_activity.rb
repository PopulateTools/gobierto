# frozen_string_literal: true

module Publishers
  class GobiertoCmsSectionActivity
    include Publisher
    self.pub_sub_namespace = 'activities/gobierto_cms_sections'
  end
end
