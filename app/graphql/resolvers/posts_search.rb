require 'search_object/plugin/graphql'

class Resolvers::PostsSearch
  # include SearchObject for GraphQL
  include SearchObject.module(:graphql)

  # inline input type definition for the advance filter
  class PostFilter < ::Types::BaseInputObject
    argument :AND, [self], required: false
    argument :OR, [self], required: false
    argument :description_contains, String, required: false
    argument :title_contains, String, required: false
  end

  option :filter, type: PostFilter, with: :apply_filter
  option :first, type: types.Int, with: :apply_first
  option :skip, type: types.Int, with: :apply_skip
    
  def apply_first(scope, value)
    scope.limit(value)
  end

  def apply_skip(scope, value)
    scope.offset(value)
  end

  # scope is starting point for search
  scope { Post.all }

  type types[Types::PostType]

  

  # when "filter" is passed "apply_filter" would be called to narrow the scope
  option :filter, type: PostFilter, with: :apply_filter

  # apply_filter recursively loops through "OR" branches
  def apply_filter(scope, value)
    branches = normalize_filters(value).reduce { |a, b| value.include?(:and) ? a.merge(b) : a.or(b) }
    scope.merge branches
  end

  def normalize_filters(value, branches = [])
    scope = Post.all
    scope = scope.where('description LIKE ?', "%#{value[:description_contains]}%") if value[:description_contains]
    scope = scope.where('title LIKE ?', "%#{value[:title_contains]}%") if value[:title_contains]

    branches << scope

    value[:or].reduce(branches) { |s, v| normalize_filters(v, s) } if value[:or].present?
    value[:and].reduce(branches) { |s, v| normalize_filters(v, s) } if value[:and].present?
    branches
  end
end