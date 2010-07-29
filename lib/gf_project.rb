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
    @connection.from(:parameter).
    filter(:code => 'Bulk_Server_Command').
    get(:value_string)
  end
    
  def connect(password = nil, &block)
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
    if block 
      yield(self)
      disconnect
    end
    self
  end
  
  def disconnect
    @connection.disconnect if @connection
  end
  
  def super_server_command
    @connection.from(:project).get(:super_server_command)
  end
  
  private
  def attempt_connect(password)
    Sequel.oracle(:database => ENV[:TWO_TASK], :user => @account, :password => password, :test => true)
  end
  
  def connect_with_default_password
    begin
      attempt_connect @name
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
        attempt_connect $1.chomp
      end
    rescue Errno::ENOENT
      raise RuntimeError, 'proj_get_password not found'
    end
  end
  
  def connect_with_supplied_password(password)
    begin
      attempt_connect password
    rescue Sequel::DatabaseConnectionError
      raise RuntimeError, "project password \"#{password}\" is not valid"
    end
  end
end
