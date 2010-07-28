$: << File.expand_path('..', __FILE__)

require 'gf_catalog'

class GFProject
  attr_accessor :name
  attr_accessor :account
  
  def initialize(name, account)
    @name = name
    @account = account
  end
end
