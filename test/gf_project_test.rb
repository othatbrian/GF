$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'gf_project'

class GFProjectTest < Test::Unit::TestCase
  def test_name_is_readable
    project = GFProject.new :test1, :TEST1, :test1
    assert_equal :test1, project.name
  end
  
  def test_account_is_readable
    project = GFProject.new :test1, :TEST1, :test1
    assert_nothing_raised { project.account }
  end

  def test_password_invalid_default_invalid_GFDBA_not_set_message
    unset_gfdba_password do
      assert_block do
        begin
          GFProject.new :test2, :TEST2, :foo
        rescue
          $!.to_s == 'project password "foo" is not valid and project default password is not valid and GFDBA_PASSWORD is not set'
        end
      end
    end
  end
  
  def test_password_not_set_default_invalid_GFDBA_not_set_message
    unset_gfdba_password do
      assert_block do
        begin
          GFProject.new :test2, :TEST2
        rescue
          $!.to_s == 'project password is not set and project default password is not valid and GFDBA_PASSWORD is not set'
        end
      end
    end
  end

  def test_password_invalid_default_invalid_GFDBA_invalid_message
    unset_gfdba_password do
      ENV[:GFDBA_PASSWORD] = :bogus
      assert_block do
        begin
          GFProject.new :test2, :TEST2, :foo
        rescue
          $!.to_s == 'project password "foo" is not valid and project default password is not valid and GFDBA_PASSWORD is not valid'
        end
      end
    end
  end
 
  def test_password_not_set_default_invalid_GFDBA_invalid_message
    unset_gfdba_password do
      ENV[:GFDBA_PASSWORD] = :bogus
      assert_block do
        begin
          GFProject.new :test2, :TEST2
        rescue
          $!.to_s == 'project password is not set and project default password is not valid and GFDBA_PASSWORD is not valid'
        end
      end
    end
  end

#  def test_bulk_server_command
#    project = GFProject.new :test1, :TEST1
#    assert_equal 'foo', project.bulk_server_command
#  end

  private
  def unset_gfdba_password
    gfdba = ENV[:GFDBA_PASSWORD] if ENV[:GFDBA_PASSWORD]
    ENV[:GFDBA_PASSWORD] = nil
    yield
    ENV[:GFDBA_PASSWORD] = gfdba if gfdba
  end
end
