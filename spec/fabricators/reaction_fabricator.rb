# frozen_string_literal: true

Fabricator(:reaction, class_name: 'DiscourseMultiReactions::Reaction') do
  post { |attrs| attrs[:post] }
  reaction_type 0
  reaction_value 'otter'
end
