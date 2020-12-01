import { withPluginApi } from "discourse/lib/plugin-api";
import { replaceIcon } from "discourse-common/lib/icon-library";

replaceIcon("notification.reaction", "bell");

function initializeDiscourseMultiReactions(api) {
  api.removePostMenuButton("like");

  api.addKeyboardShortcut("l", () => {
    const button = document.querySelector(
      ".topic-post.selected .discourse-multi-reactions-reaction-button"
    );
    button && button.click();
  });

  api.decorateWidget("post-menu:before-extra-controls", dec => {
    const post = dec.getModel();

    if (!post) {
      return;
    }

    return dec.attach("discourse-multi-reactions-actions", {
      post
    });
  });
}

export default {
  name: "discourse-multi-reactions",

  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    if (siteSettings.discourse_multi_reactions_enabled) {
      withPluginApi("0.10.1", initializeDiscourseMultiReactions);
    }
  }
};
