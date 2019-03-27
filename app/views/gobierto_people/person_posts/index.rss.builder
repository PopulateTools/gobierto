# frozen_string_literal: true

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title t("gobierto_people.layouts.menu_subsections.blogs")
    xml.description t("gobierto_people.layouts.menu_subsections.blogs")
    xml.link gobierto_people_posts_url(format: :rss)
    xml.tag! "atom:link", :rel => "self", :type => "application/rss+xml", :href => gobierto_people_posts_url(format: :rss)

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.body.html_safe
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link gobierto_people_person_post_url(post.person, post)
        xml.guid gobierto_people_person_post_url(post.person, post)
      end
    end
  end
end
