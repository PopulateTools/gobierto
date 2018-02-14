module GobiertoPeople
  module NavigationItems
    def test_absence_of_links_for_empty_groups
      Person.all.each(&:delete)
      with_current_site(site) do
        visit @path

          within ".filter_boxed" do
            assert has_no_link?('Government Team')
            assert has_no_link?('Opposition')
            assert has_no_link?('Executive')
            assert has_no_link?("Political groups")
        end
      end
    end

    def test_blog_link
      with_current_site(site) do
        visit @path

        within 'nav.sub-nav' do
          assert has_link? 'Blogs'
        end
      end
    end
  end
end
