require 'sinatra'
require 'yacs_catalog_service/catalog'

%w(sections courses departments schools).each do |resource|
  get "/#{resource}" {json: { resource => Catalog.send(resource) }}
end
