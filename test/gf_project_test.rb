$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'gf_project'

class GFProjectTest < Test::Unit::TestCase
  def test_name_is_readable
    project = GFProject.new :test, :TEST
    assert_equal :test, project.name
  end

  def test_name_is_writable
    project = GFProject.new :test, :TEST
    assert_nothing_raised { project.name = :test }
  end

  def test_account_is_readable
    project = GFProject.new :test, :TEST
    assert_nothing_raised { project.account }
  end

  def test_account_is_writable
    project = GFProject.new :test, :TEST
    assert_nothing_raised { project.account = :test }
  end
end
