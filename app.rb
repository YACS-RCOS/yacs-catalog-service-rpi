require 'sinatra'
require 'sinatra/json'
require './lib/catalog'


set :bind, '0.0.0.0'
catalog = Catalog::Aggregator.new

%w(sections courses departments schools).each do |resource|
  get "/#{resource}" do 
  	json resource => catalog.send(resource)
  end
end
