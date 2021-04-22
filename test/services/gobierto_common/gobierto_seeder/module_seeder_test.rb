# frozen_string_literal: true

require "test_helper"

class GobiertoCommon::GobiertoSeeder::ModuleSeederTest < ActiveSupport::TestCase
  def setup
    super
    @subject = GobiertoCommon::GobiertoSeeder::ModuleSeeder
    @recipe_spy = Spy.on(::GobiertoSeeds::GobiertoPeople::Recipe, :run)
  end

  attr_reader :recipe_spy

  def first_call_arguments
    recipe_spy.calls.first.args
  end

  def seeds_path
    @seeds_path ||= Rails.root.join("db/seeds/gobierto_seeds/sites/gobierto_populate/gobierto_people/recipe")
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_seed_a_site_with_that_module
    @subject.seed("GobiertoPeople", site)
    assert recipe_spy.has_been_called?
    args = first_call_arguments
    assert_equal site, args.first
  end
end
