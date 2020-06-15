# frozen_string_literal: true

require 'rails_helper'
require_relative '../fabricators/reaction_fabricator.rb'
require_relative '../fabricators/reaction_user_fabricator.rb'

describe DiscourseReactions::CustomReactionsController do
  fab!(:post_1) { Fabricate(:post) }
  fab!(:user_1) { Fabricate(:user) }
  fab!(:user_2) { Fabricate(:user) }

  context 'POST' do
    it 'creates reaction record if does not exists and cache count' do
      sign_in(user_1)
      expected_reactions_payload = [
        {
          'id' => 'thumbsup',
          'type' => 'emoji',
          'users' => [
            { 'username' => user_1.username, 'avatar_template' => user_1.avatar_template }
          ],
          'count' => 1
        }
      ]
      post '/discourse-reactions/custom_reactions.json', params: { post_id: post_1.id, reaction: 'thumbsup' }
      expect(DiscourseReactions::Reaction.count).to eq(1)
      expect(DiscourseReactions::ReactionUser.count).to eq(1)
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['reactions']).to eq(expected_reactions_payload)

      post '/discourse-reactions/custom_reactions.json', params: { post_id: post_1.id, reaction: 'thumbsup' }
      expect(DiscourseReactions::Reaction.count).to eq(1)
      expect(DiscourseReactions::ReactionUser.count).to eq(1)
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['reactions']).to eq(expected_reactions_payload)

      reaction = DiscourseReactions::Reaction.last
      expect(reaction.reaction_value). to eq('thumbsup')
      expect(reaction.count_cache). to eq(1)

      sign_in(user_2)
      post '/discourse-reactions/custom_reactions.json', params: { post_id: post_1.id, reaction: 'thumbsup' }
      reaction = DiscourseReactions::Reaction.last
      expect(reaction.reaction_value). to eq('thumbsup')
      expect(reaction.count_cache). to eq(2)
    end

    it 'errors when emoji is invalid' do
      post '/discourse-reactions/custom_reactions.json', params: { post_id: post_1.id, reaction: 'invalid_emoji' }
      expect(DiscourseReactions::Reaction.count).to eq(0)
      expect(response.status).to eq(422)
    end
  end

  context 'DELETE' do
    it 'deletes reaction if exists' do
      sign_in(user_1)
      reaction = Fabricate(:reaction, post: post_1, count_cache: 2)
      Fabricate(:reaction_user, reaction: reaction, user: user_1)
      Fabricate(:reaction_user, reaction: reaction, user: user_2)

      delete '/discourse-reactions/custom_reactions.json', params: { post_id: post_1.id, reaction: 'otter' }
      expect(response.status).to eq(200)
      expect(reaction.reload.count_cache).to eq(1)

      sign_in(user_2)
      delete '/discourse-reactions/custom_reactions.json', params: { post_id: post_1.id, reaction: 'otter' }
      expect { reaction.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
