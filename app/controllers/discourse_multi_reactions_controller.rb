# frozen_string_literal: true

module DiscourseMultiReactions
  class DiscourseMultiReactionsController < ::ApplicationController
    requires_plugin :discourse_multi_reactions
  end
end
