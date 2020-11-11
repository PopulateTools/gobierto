# frozen_string_literal: true

module Publishers
  class GobiertoCmsSectionItemActivity
    include Publisher
    self.pub_sub_namespace = 'activities/gobierto_cms_section_items'
  end
end
