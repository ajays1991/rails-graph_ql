require 'search_object/plugin/graphql'

class Resolvers::LinksSearch
  # include SearchObject for GraphQL
  include SearchObject.module(:graphql)

  # inline input type definition for the advance filter
  class LinkFilter < ::Types::BaseInputObject
    argument :OR, [self], required: false
    argument :description_contains, String, required: false
    argument :url_contains, String, required: false
  end

  option :filter, type: LinkFilter, with: :apply_filter
  option :first, type: types.Int, with: :apply_first
  option :skip, type: types.Int, with: :apply_skip
    
  def apply_first(scope, value)
    scope.limit(value)
  end

  def apply_skip(scope, value)
    scope.offset(value)
  end

  # scope is starting point for search
  scope { Link.all }

  type types[Types::LinkType]

  

  # when "filter" is passed "apply_filter" would be called to narrow the scope
  option :filter, type: LinkFilter, with: :apply_filter

  # apply_filter recursively loops through "OR" branches
  def apply_filter(scope, value)
    byebug
    branches = normalize_filters(value).reduce { |a, b| a.or(b) }
    scope.merge branches
  end

  def normalize_filters(value, branches = [])
    byebug
    scope = Link.all
    scope = scope.where('description LIKE ?', "%#{value[:description_contains]}%") if value[:description_contains]
    scope = scope.where('url LIKE ?', "%#{value[:url_contains]}%") if value[:url_contains]

    branches << scope

    value[:or].reduce(branches) { |s, v| normalize_filters(v, s) } if value[:or].present?

    branches
  end
end