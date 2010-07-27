require 'sequel'
require 'gf_project'

class GFCatalog
  def self.projects
    return @projects if @projects
    raise 'ERROR: TWO_TASK is not set' unless ENV[:TWO_TASK]
    raise 'ERROR: BASELINE_ACC is not set' unless ENV[:BASELINE_ACC]
    raise 'ERROR: GFPUBLIC_USERID is not set' unless ENV[:GFPUBLIC_USERID]
    db = ENV[:TWO_TASK]
    user, pass = ENV[:GFPUBLIC_USERID].split('/')
    @projects = []
    Sequel.oracle(:database => db, :user => user, :password => pass) do |db|
      db[:finder_accounts].
      select(:project_name).
      exclude(:type => ['PROJSYS', 'SYSTEM']).
      exclude(:account_name => 'CODES').
      exclude(:project_id => 0).
      filter(:baseline_account => ENV[:BASELINE_ACC]).
      filter(:project_type => 'STANDALONE').
      order(:project_name).
      each do |name|
        @projects << GFProject.new(:name)
			end
    end
		@projects
  end
end
