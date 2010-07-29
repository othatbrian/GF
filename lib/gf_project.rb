$: << File.expand_path('..', __FILE__)

require 'open3'
require 'gf_catalog'

class GFProject
  attr_reader :name
  attr_reader :account
  
  def initialize(name, account, password = nil)
    @name = name
    @account = account
    
    catch :connected do
      errors = ''
      if password
        begin
          throw(:connected) if @connection = connect_with_supplied_password(password)
        rescue
          errors = $!.to_s
        end
      else
        errors = "project password is not set" unless password
      end
      begin
        throw(:connected) if @connection = connect_with_default_password
      rescue
        errors += " and " + $!.to_s
      end
      if ENV[:GFDBA_PASSWORD]
        begin
          throw(:connected) if @connection = connect_with_gfdba_password
        rescue
          errors += " and " + $!.to_s
        end
      else
        errors += " and GFDBA_PASSWORD is not set"
      end
      raise(RuntimeError, errors)
    end
    
    @password = password
    self
  end
  
  def bulk_server_command
    @connection[:parameter].
    select(:value_string).
    filter(:code => 'Bulk_Server_Command').
    first[:value_string]
  end
  
  def super_server_command
    @connection[:project].
    select(:super_server_command).
    first[:super_server_command]
  end
  
  private
  def connect(password)
    Sequel.oracle(:database => ENV[:TWO_TASK], :user => @account, :password => password, :test => true)
  end
  
  def connect_with_default_password
    begin
      connect @name
    rescue Sequel::DatabaseConnectionError
      raise RuntimeError, 'project default password is not valid'
    end
  end
  
  def connect_with_gfdba_password
    begin
      Open3.popen3("proj_get_password #{name} bogus") do |stdin, stdout, stderr|
        errors = stderr.read
        if errors =~ /^Invalid password/m
          raise RuntimeError, 'GFDBA_PASSWORD is not valid'
        end
        stdout.read =~ /^Password =(.*)$/m
        connect $1.chomp
      end
    rescue Errno::ENOENT
      raise RuntimeError, 'proj_get_password not found'
    end
  end
  
  def connect_with_supplied_password(password)
    begin
      connect password
    rescue Sequel::DatabaseConnectionError
      raise RuntimeError, "project password \"#{password}\" is not valid"
    end
  end
end
