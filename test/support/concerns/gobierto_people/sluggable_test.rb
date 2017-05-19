module GobiertoPeople::SluggableTestModule

  def test_assings_slug_on_creation
    sluggable_1 = create_sluggable
    sluggable_2 = create_sluggable

    assert sluggable_1.slug.present?
    assert sluggable_2.slug.present?
    assert (sluggable_2.slug =~ /-2$/) > 0
    assert_not_equal sluggable_1.slug, sluggable_2.slug
  end

end
