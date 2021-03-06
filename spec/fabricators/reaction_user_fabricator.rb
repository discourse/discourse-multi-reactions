# frozen_string_literal: true

Fabricator(:reaction_user, class_name: 'DiscourseMultiReactions::ReactionUser') do
  reaction { |attrs| attrs[:reaction] }
  user { |attrs| attrs[:user] }
end
