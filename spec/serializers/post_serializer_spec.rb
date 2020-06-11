# frozen_string_literal: true

require 'rails_helper'
require_relative '../fabricators/reaction_fabricator.rb'


describe PostSerializer do
  fab!(:user) { Fabricate(:user) }
  fab!(:user2) { Fabricate(:user) }
  fab!(:post) { Fabricate(:post, user: user) }
  fab!(:reaction) { Fabricate(:reaction, post: post, user: user) }
  fab!(:reaction2) { Fabricate(:reaction, post: post, user: user2) }
  fab!(:reaction2) { Fabricate(:reaction, reaction_value: "thumbs-up", post: post, user: user2) }

  it 'renders custom reactions' do
    json = PostSerializer.new(post, scope: Guardian.new(user), root: false).as_json
    expect(json[:reactions]).to eq([
      {
        id: 'otter',
        type: :emoji,
        users: [
          { username: user.username, avatar_template: user.avatar_template },
          { username: user2.username, avatar_template: user2.avatar_template }
        ],
        count: 2
      },
      {
        id: 'thumbs-up',
        type: :emoji,
        users: [
          { username: user2.username, avatar_template: user2.avatar_template }
        ],
        count: 1
      }
    ])
  end

  context 'disabled' do
    it 'is not extending post serializer when plugin is disabled' do
      SiteSetting.discourse_reactions_enabled = false
      json = PostSerializer.new(post, scope: Guardian.new(user), root: false).as_json
      expect(json[:reactions]).to be false
    end
  end
end
