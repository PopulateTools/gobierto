module GobiertoPeople
  module NavigationItems
    def test_absence_of_links_for_empty_groups
      Person.all.each(&:delete)
      with_current_site(site) do
        visit @path

          within ".filter_boxed" do
            refute has_link?('Government Team')
            refute has_link?('Opposition')
            refute has_link?('Executive')
            refute has_link?("Political groups")
        end
      end
    end

    def test_blog_link
      with_current_site(site) do
        visit @path

        within '.sub-nav' do
          assert has_link? 'Blogs'
        end
      end
    end
  end
end
