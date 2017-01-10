require 'sinatra'
require 'yacs_catalog_service/catalog'

get '/sections' do
  json: { sections: Catalog.sections }
end

get '/courses' do
  json: { courses: Catalog.courses }
end

get '/departments' do 
  json: { departments: Catalog.departments }
end

get '/schools' do
  json: { schools: Catalog.schools }
end
