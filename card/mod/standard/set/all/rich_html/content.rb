def show_comment_box_in_related?
  false
end

def help_rule_card
  setting = new_card? ? [:add_help, { fallback: :help }] : :help
  help_card = rule_card(*setting)
  help_card if help_card&.ok?(:read)
end

format :html do
  def prepare_content_slot
    class_up "card-slot", "d0-card-content"
    voo.hide :menu
  end

  before(:content) { prepare_content_slot }

  view :content do
    wrap { [_render_menu, _render_core] }
  end

  before(:content_with_title) { prepare_content_slot }

  view :content_with_title do
    wrap true, title: card.format(:text).render_core do
      [_render_menu, _render_core]
    end
  end

  before :content_panel do
    prepare_content_slot
    class_up "card-slot", "card", true
  end

  view :content_panel do
    wrap do
      wrap_with :div, class: "card-body" do
        [_render_menu, _render_core]
      end
    end
  end

  view :titled, tags: :comment do
    @content_body = true
    wrap do
      [
        # _render_menu,
        _render_header,
        wrap_body { _render_titled_content },
        render_comment_box
      ]
    end
  end

  # view :property do
  #   voo.title ||= card.name.right
  #   render_labeled
  # end

  view :labeled, tags: :unknown_ok do
    @content_body = true
    voo.edit = :content_modal
    menu = wrap_menu { _render_menu }
    wrap(true, class: "row") do
      labeled(render_title, wrap_body { [menu, render_labeled_content] })
    end
  end

  def labeled label, content
    haml :labeled, label: label, content: content
  end

  view :open, tags: :comment do
    voo.viz :toggle, (main? ? :hide : :show)
    @content_body = true
    frame do
      [_render_open_content, render_comment_box]
    end
  end

  view :type do
    link_to_card card.type_card, nil, class: "cardtype"
  end

  view :closed do
    with_nest_mode :closed do
      voo.show :toggle
      class_up "d0-card-body", "closed-content"
      @content_body = true
      @toggle_mode = :close
      frame { _render :closed_content }
    end
  end

  view :change do
    voo.show :title_link
    voo.hide :menu
    wrap do
      [_render_title,
       _render_menu,
       _render_last_action]
    end
  end

  def current_set_card
    set_name = params[:current_set]
    set_name ||= "#{card.name}+*type" if card.known? && card.type_id == Card::CardtypeID
    set_name ||= "#{card.name}+*self"
    Card.fetch(set_name)
  end

  view :help, tags: :unknown_ok, cache: :never do
    help_text = voo.help || rule_based_help
    return "" unless help_text.present?

    wrap_with :div, help_text, class: classy("help-text")
  end

  def rule_based_help
    return "" unless (rule_card = card.help_rule_card)

    with_nest_mode :normal do
      process_content rule_card.content, chunk_list: :references
      # render help card with current card's format
      # so current card's context is used in help card nests
    end
  end

  view :last_action do
    act = card.last_act
    return unless act

    action = act.action_on card.id
    return unless action

    action_verb =
      case action.action_type
      when :create then "added"
      when :delete then "deleted"
      else
        link_to "edited", path: { view: :history }, class: "last-edited", rel: "nofollow"
      end

    %(
      <span class="last-update">
        #{action_verb} #{_render_acted_at} ago by
        #{subformat(card.last_actor)._render_link}
      </span>
    )
  end
end
