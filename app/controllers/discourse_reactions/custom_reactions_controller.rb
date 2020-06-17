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

    def toggle
      return render_json_error(@post) unless DiscourseReactions::Reaction.valid_reactions.include?(params[:reaction])
      ActiveRecord::Base.transaction do
        reaction = reaction_scope.first_or_create
        reaction_user = reaction_user_scope(reaction)&.first_or_initialize

        if reaction_user.persisted?
          reaction_user.destroy
          remove_shadow_like(reaction)
        else
          reaction_user.save!
          add_shadow_like_and_notify(reaction)
        end
        reaction.destroy if reaction.reload.reaction_users_count == 0
      end

      render_json_dump(post_serializer.as_json)
    end

    private 

    def add_shadow_like_and_notify(reaction)
      return if DiscourseReactions::Reaction.positive.where(post_id: @post.id).by_user(current_user).count != 1
      PostActionCreator.like(current_user, @post) if reaction.positive?
      # if reaction.negative_or_neutral?
      # TODO
      # notification when reaction is negative or neutral
      # ideally, I would like to hook to PostAlerter because there is a lot of useful logic there like for example don't create notification when user is muted and
      # respect user preferences about how often they want to receive like notifications
      # I think it will be possible and that is a goal
    end

    def remove_shadow_like(reaction)
      return if DiscourseReactions::Reaction.positive.where(post_id: @post.id).by_user(current_user).count != 0
      PostActionDestroyer.new(current_user, @post, PostActionType.types[:like]).perform if reaction.positive?
    end

    def reaction_scope
      DiscourseReactions::Reaction.where(post_id: @post.id,
                                         reaction_value: params[:reaction],
                                         reaction_type:  DiscourseReactions::Reaction.reaction_types['emoji'])
    end

    def reaction_user_scope(reaction)
      return nil unless reaction
      DiscourseReactions::ReactionUser.where(reaction_id: reaction.id, user_id: current_user.id)
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
