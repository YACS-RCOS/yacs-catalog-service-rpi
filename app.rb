require 'sinatra'
require './lib/catalog'

%w(sections courses departments schools).each do |resource|
  get "/#{resource}", { json: { resource => Catalog.send(resource) } }
end
