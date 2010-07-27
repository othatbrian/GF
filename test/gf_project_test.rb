$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'gf_project'

class GFProjectTest < Test::Unit::TestCase
  def test_name_is_required
    assert_raise(ArgumentError) { GFProject.new }
  end

  def test_name_is_readable
    project = GFProject.new :test
    assert_equal :test, project.name
  end

  def test_name_is_writable
    project = GFProject.new :test
    assert_nothing_raised { project.name = :test }
  end
end
