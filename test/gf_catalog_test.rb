$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'gf_catalog'

class GFProjectTest < Test::Unit::TestCase
  def setup
    @two_task = ENV[:TWO_TASK] if ENV[:TWO_TASK]
    ENV[:TWO_TASK] = :TESTDB
    @baseline_acc = ENV[:BASELINE_ACC] if ENV[:BASELINE_ACC]
    ENV[:BASELINE_ACC] = :GF4
    @gfpublic_userid = ENV[:GFPUBLIC_USERID] if ENV[:GFPUBLIC_USERID]
    ENV[:GFPUBLIC_USERID] = 'gf_public/gf_public'
  end

  def teardown
    ENV[:TWO_TASK] = @two_task ? @two_task : nil
    ENV[:BASELINE_ACC] = @baseline_acc ? @baseline_acc : nil
    ENV[:GFPUBLIC_USERID] = @gfpublic_userid ? @gfpublic_userid : nil
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

  def test_projects_requires_TWO_TASK
    ENV[:TWO_TASK] = nil
    assert_raises(RuntimeError) { GFCatalog.projects.first }
  end

  def test_projects_requires_BASELINE_ACC
    ENV[:BASELINE_ACC] = nil
    assert_raises(RuntimeError) { GFCatalog.projects.first }
  end

  def test_projects_requires_GFPUBLIC_USERID
    ENV[:GFPUBLIC_USERID] = nil
    assert_raises(RuntimeError) { GFCatalog.projects.first }
  end
end
