$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'gf_catalog'

class GFProjectTest < Test::Unit::TestCase
  def setup
    GFCatalog.instance_eval { @projects = nil }
    GFCatalog.instance_eval { @accounts = nil }
  end

  def test_projects_returns_array
    assert_instance_of Array, GFCatalog.projects
  end

  def test_projects_uses_instance_variable
    GFCatalog.projects
    ENV[:TWO_TASK] = nil
    assert_equal 2, GFCatalog.projects.length
  end

  def test_projects_returns_GFProject_objects
    assert_instance_of GFProject, GFCatalog.projects.first
  end
end
