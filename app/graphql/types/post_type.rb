module Types
	class PostType < BaseObject
		field :id, ID, null: false
		field :title, String, null: false
		field :description, String, null: false
		field :author, UserType, null: true, method: :user
	end
end