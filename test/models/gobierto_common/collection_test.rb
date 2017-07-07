require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def process
    @process ||= gobierto_participation_processes(:green_city)
  end

  def page
    @page ||= gobierto_cms_pages(:privacy)
  end

  def issue
    @issue ||= gobierto_participation_issues(:culture)
  end

  def area
    @area ||= gobierto_participation_areas(:north)
  end

  def test_append_with_process_container
    assert_difference 'GobiertoCommon::CollectionItem.count', 3 do
      GobiertoCommon::Collection.find(site, process).append(page)
    end

    assert GobiertoCommon::CollectionItem.exists?(item: page, container: site)
    assert GobiertoCommon::CollectionItem.exists?(item: page, container: process)
    assert GobiertoCommon::CollectionItem.exists?(item: page, container_type: "GobiertoParticipation")
  end

  def test_append_with_module_container
    assert_difference 'GobiertoCommon::CollectionItem.count', 2 do
      GobiertoCommon::Collection.find(site, GobiertoParticipation).append(process)
    end

    assert GobiertoCommon::CollectionItem.exists?(item: process, container: site)
    assert GobiertoCommon::CollectionItem.exists?(item: process, container_type: "GobiertoParticipation")
  end

  def test_append_with_issue_container
    assert_difference 'GobiertoCommon::CollectionItem.count', 2 do
      GobiertoCommon::Collection.find(site, issue).append(process)
    end

    assert GobiertoCommon::CollectionItem.exists?(item: process, container: site)
    assert GobiertoCommon::CollectionItem.exists?(item: process, container: area)
  end

  def test_append_with_area_container
    assert_difference 'GobiertoCommon::CollectionItem.count', 2 do
      GobiertoCommon::Collection.find(site, area).append(process)
    end

    assert GobiertoCommon::CollectionItem.exists?(item: process, container: site)
    assert GobiertoCommon::CollectionItem.exists?(item: process, container: area)
  end

  def test_append_with_site_container
    assert_difference 'GobiertoCommon::CollectionItem.count', 1 do
      GobiertoCommon::Collection.find(site).append(page)
    end

    assert GobiertoCommon::CollectionItem.exists?(item: page, container: site)
  end
end
