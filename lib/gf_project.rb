$: << File.expand_path('..', __FILE__)

require 'open3'
require 'gf_catalog'

class GFProject
  attr_reader :name
  attr_reader :account
  
  def initialize(name, account)
    @name = name
    @account = account
  end
  
  def bulk_server_command
    query do |db|
      db.from(:parameter).filter(:code => 'Bulk_Server_Command').get(:value_string)
    end
  end
  
  def password(password = nil)
    catch :success do
      errors = ''
      if password
        begin
          throw(:success) if connect_with_supplied_password(password)
        rescue
          errors = $!.to_s
        end
      else
        errors = "project password is not set" unless password
      end
      begin
        throw(:success) if connect_with_default_password
      rescue
        errors += " and " + $!.to_s
      end
      if ENV[:GFDBA_PASSWORD]
        begin
          throw(:success) if connect_with_gfdba_password
        rescue
          errors += " and " + $!.to_s
        end
      else
        errors += " and GFDBA_PASSWORD is not set"
      end
      raise(RuntimeError, errors)
    end
    self
  end
  
  def last_modified
    query do |db|
      db.from(:project).get(:modify_date)
    end
  end
  
  def super_server_command
    query do |db|
      db.from(:project).get(:super_server_command)
    end
  end
  
  private
  def attempt_connect(password)
    Sequel.oracle(:database => ENV[:TWO_TASK], :user => @account, :password => password, :test => true) { |db| db.disconnect }
  end
  
  def connect_with_default_password
    begin
      attempt_connect @name
      @password = @name
    rescue Sequel::DatabaseConnectionError
      raise RuntimeError, 'project default password is not valid'
    end
  end
  
  def connect_with_gfdba_password
    begin
      Open3.popen3("proj_get_password #{@name} bogus") do |stdin, stdout, stderr|
        errors = stderr.read
        if errors =~ /^Invalid password/m
          raise RuntimeError, 'GFDBA_PASSWORD is not valid'
        end
        stdout.read =~ /^Password =(.*)$/m
        attempt_connect $1.chomp
        @password = $1.chomp
      end
    rescue Errno::ENOENT
      raise RuntimeError, 'proj_get_password not found'
    end
  end
  
  def connect_with_supplied_password(password)
    begin
      attempt_connect password
      @password = password
    rescue Sequel::DatabaseConnectionError
      raise RuntimeError, "project password \"#{password}\" is not valid"
    end
  end
  
  def query(&block)
    password unless @password
    Sequel.oracle(:database => ENV[:TWO_TASK], :user => @account, :password => @password) do |db|
      yield db
    end
  end
end
