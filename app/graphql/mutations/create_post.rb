module Mutations
	class CreatePost < BaseMutation
		# arguments passed to resolved method
		argument :description, String, required: true
		argument :title, String, required: true

		# return type from the mutation

		type Types::PostType

		def resolve(description: nil, title: nil)
			Post.create!(
				description: description,
				title: title,
				user: context[:current_user]
			)
		end
	end
end