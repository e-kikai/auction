module ApplicationHelper
  require "redcarpet"

  ### md2HTML変換 ###
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

  ### JSON-LD 生成 ###
  def jsonld_script_tag
    jsonld = controller.render_to_string(formats: :jsonld)
    content_tag :script, jsonld.html_safe, type: Mime[:jsonld].to_s
  rescue ActionView::ActionViewError => e
    # logger.error e.message
    nil
  ensure
     # render_to_string のバグ回避 https://github.com/rails/rails/issues/14173
    lookup_context.rendered_format = nil
  end

end
