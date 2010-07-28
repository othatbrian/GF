$: << File.expand_path('..', __FILE__)

require 'sequel'
require 'gf_project'

class GFCatalog
  raise 'ERROR: TWO_TASK is not set' unless ENV[:TWO_TASK]
  raise 'ERROR: BASELINE_ACC is not set' unless ENV[:BASELINE_ACC]
  raise 'ERROR: GFPUBLIC_USERID is not set' unless ENV[:GFPUBLIC_USERID]

  @db = ENV[:TWO_TASK]
  @user, @pass = ENV[:GFPUBLIC_USERID].split('/')

  def self.projects
    return @projects if @projects
    @projects = []
    Sequel.oracle(:database => @db, :user => @user, :password => @pass) do |db|
      projects_ds(db).each do |row|
        @projects << GFProject.new(row[:project_name], row[:account_name])
      end
    end
    @projects
  end
  
  def self.account(name)
    Sequel.oracle(:database => @db, :user => @user, :password => @pass) do |db|
      projects_ds(db).filter(:project_name => 'test1').first[:account_name]
    end
  end
  
  private
  def self.projects_ds(db)
    raise TypeError unless db.is_a? Sequel::Database
    db[:finder_accounts].
    select(:project_name, :account_name).
    exclude(:type => ['PROJSYS', 'SYSTEM']).
    exclude(:account_name => 'CODES').
    exclude(:project_id => 0).
    filter(:baseline_account => ENV[:BASELINE_ACC]).
    filter(:project_type => 'STANDALONE').
    order(:project_name)
  end
end
