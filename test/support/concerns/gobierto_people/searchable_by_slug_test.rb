module GobiertoPeople::SearchableBySlugTest

  def test_generate_unique_slug
    slug_1 = subject_class.generate_unique_slug('--Convert_mE *In-_(SLUG)!2')
    slug_2 = subject_class.generate_unique_slug('--Convert_mE *In-_(SLUG)!2', Time.zone.parse('2017-02-10'))

    assert_equals 'convert-me-in-slug2', slug_1
    assert_equals '2017-02-10-convert-me-in-slug2', slug_2
  end

end
