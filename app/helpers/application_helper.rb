module ApplicationHelper
  require "redcarpet"

  def markdown(text)
    render_options = {
      filter_html: false,
      hard_wrap:   true
    }
    renderer = Redcarpet::Render::HTML.new(render_options)

    extensions = {
      autolink:           true,
      fenced_code_blocks: true,
      lax_spacing:        true,
      no_intra_emphasis:  true,
      strikethrough:      true,
      superscript:        true,
      tables:             true,
    }
    content_tag(:div, class: "markdown-area") do
      Redcarpet::Markdown.new(renderer, extensions).render(text.to_s).html_safe
    end
  end
end
