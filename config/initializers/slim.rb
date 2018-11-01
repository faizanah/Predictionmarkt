require 'slim'
require 'tilt'
require 'redcarpet'

renderer_class = BlogHelper::MarkdownRenderer
# renderer_class = Redcarpet::Render::HTML
render_options = {
  # https://github.com/vmg/redcarpet#darling-i-packed-you-a-couple-renderers-for-lunch
  filter_html: false,
  no_images: false,
  no_links: false,
  no_styles: false,
  safe_links_only: false,
  with_toc_data: false,
  hard_wrap: false,
  xhtml: false,
  prettify: false,
  link_attributes: {}
}
renderer = renderer_class.new(render_options)

markdown_extensions = {
  # https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
  no_intra_emphasis: false,
  tables: false,
  fenced_code_blocks: false,
  autolink: false,
  disable_indented_code_blocks: false,
  strikethrough: false,
  lax_spacing: false,
  space_after_headers: false,
  superscript: false,
  underline: false,
  highlight: false,
  quote: false,
  footnotes: false,
  renderer: renderer
}

# https://github.com/slim-template/slim/issues/245#issuecomment-8833818
Slim::Embedded.set_options markdown: markdown_extensions
