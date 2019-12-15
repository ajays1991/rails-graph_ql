module Types
  class QueryType < Types::BaseObject
    field :show_posts, [PostType], null: false
    field :all_links, [LinkType], null: false
    field :all_links_search, function: Resolvers::LinksSearch
    field :all_posts_search, function: Resolvers::PostsSearch
    def all_links
      Link.all
    end

    def show_posts
      Post.all
    end
  end
end
