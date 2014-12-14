require 'test_helper'
require 'generators/harvester/harvester_generator'

class HarvesterGeneratorTest < Rails::Generators::TestCase
  tests HarvesterGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
