require 'rails_helper'

RSpec.describe GobiertoCms::Page, type: :model do
  before do
    @site = create_site
  end

  describe '#parents' do
    it 'should return the list of the parents' do
      parent_page = create_gobierto_cms_page site: @site
      page = create_gobierto_cms_page site: @site, parent: parent_page

      expect(page.parents.length).to eq(1)
    end

    it 'should return an empty array if it is a root page' do
      page = create_gobierto_cms_page site: @site

      expect(page.parents).to be_empty
    end
  end

  describe '.root scope' do
    it 'should include only parent pages' do
      parent_page = create_gobierto_cms_page site: @site
      page = create_gobierto_cms_page site: @site, parent: parent_page
      expect(parent_page.parent).to be_nil

      root_pages = described_class.root.to_a
      expect(root_pages.length).to eq(1)
      expect(root_pages).to include(parent_page)
    end
  end

  describe '#attachments callbacks' do
    it 'should associate the attachments to the page' do
      attachment = GobiertoCms::Attachment.new site: @site
      attachment.save!

      page = new_gobierto_cms_page site: @site
      page.attachments_ids = ",#{attachment.id}"
      page.save!

      attachment.reload
      expect(attachment.page).to eq(page)
      expect(page.attachments).to include(attachment)
    end
  end
end
