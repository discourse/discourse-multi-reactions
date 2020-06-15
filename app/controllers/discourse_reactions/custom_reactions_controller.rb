# frozen_string_literal: true

module DiscourseReactions
  class CustomReactionsController < DiscourseReactionsController
    before_action :fetch_post_from_params

    def index
      user = User.last

      reactions = [
        {
          id: 'otter',
          type: :emoji,
          users: [
            { username: user.username, avatar_template: user.avatar_template }
          ],
          count: 1
        },
        {
          id: 'thumbsup',
          type: :emoji,
          users: [
            { username: user.username, avatar_template: user.avatar_template },
            { username: current_user.username, avatar_template: current_user.avatar_template },
          ],
          count: 2
        }
      ]

      render json: reactions
    end

    def create
      return render_json_error(@post) unless DiscourseReactions::Reaction.valid_reactions.include?(params[:reaction])

      ActiveRecord::Base.transaction do
        @reaction = fetch_reaction
        @reaction_user = fetch_reaction_user

        unless @reaction_user.persisted?
          @reaction.update!(count_cache: @reaction.count_cache + 1)
          @reaction_user.update!(reaction_id: @reaction.id)
        end
        add_or_remove_shadow_like
      end
      render_json_dump(post_serializer.as_json)
    end

    def destroy
      ActiveRecord::Base.transaction do
        @reaction = fetch_reaction
        @reaction_user = fetch_reaction_user

        if @reaction_user
          @reaction_user.destroy
          if @reaction.count_cache > 1
            @reaction.update!(count_cache: @reaction.count_cache - 1)
          else
            @reaction.destroy
          end
        end
        add_or_remove_shadow_like
      end
      render_json_dump(post_serializer.as_json)
    end

    private 

    def add_or_remove_shadow_like
      # TODO add like when positive emoji exists and like was not already given
      # TODO remove like when all positive emojis are removed for specific user and post
    end

    def fetch_reaction
      @reaction = DiscourseReactions::Reaction.where(post_id: @post.id,
                                                     reaction_value: params[:reaction],
                                                     reaction_type:  DiscourseReactions::Reaction.reaction_types['emoji']).first_or_initialize
    end

    def fetch_reaction_user
      @reaction_user = DiscourseReactions::ReactionUser.where(reaction_id: @reaction.id,
                                                              user_id: current_user.id).first_or_initialize
    end

    def post_serializer
      PostSerializer.new(@post, scope: guardian, root: false)
    end

    def fetch_post_from_params
      @post = Post.find(params[:post_id])
      guardian.ensure_can_see!(@post)
    end
  end
end
