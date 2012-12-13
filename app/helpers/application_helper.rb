module ApplicationHelper
  def title(page_title)
    content_for :title, "refactr.it - #{page_title.to_s}"
  end

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip Devise :timeout and :timedout flags
      next if type == :timeout
      next if type == :timedout
      type = :success if type == :notice
      type = :error   if type == :alert
      text = content_tag(:div,
                         content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                         message, :class => "alert fade in alert-#{type}")
      flash_messages << text if message
    end
    flash_messages.join("\n").html_safe
  end

  def flash_block
    output = ''
    flash.each do |type, message|
      output += flash_container(type, message)
    end

    raw(output)
  end

  def flash_container(type, message)
    raw(content_tag(:div, :class => "alert alert-#{type}") do
      content_tag(:a, raw("&times;"),:class => 'close', :data => {:dismiss => 'alert'}) +
        message
    end)
  end

  # ==== Examples
  # glyph(:share_alt)
  # # => <i class="icon-share-alt"></i>
  # glyph(:lock, :white)
  # # => <i class="icon-lock icon-white"></i>

  def glyph(*names)
    content_tag :i, nil, :class => names.map{|name| "icon-#{name.to_s.gsub('_','-')}" }
  end

  def modal_dialog(options = {}, escape = true, &block)
    default_options = {:class => "bootstrap-modal modal"}
    content_tag :div, nil, options.merge(default_options), escape, &block
  end

  def modal_header(options = {}, escape = true, &block)
    default_options = {:class => 'modal-header'}
    content_tag :div, nil, options.merge(default_options), escape do
      raw("<button class=\"close\" data-dismiss=\"modal\">&times;</button>" + capture(&block))
    end
  end

  def modal_body(options = {}, escape = true, &block)
    default_options = {:class => 'modal-body'}
    content_tag :div, nil, options.merge(default_options), escape, &block
  end

  def modal_footer(options = {}, escape = true, &block)
    default_options = {:class => 'modal-footer'}
    content_tag :div, nil, options.merge(default_options), escape, &block
  end

  def modal_toggle(content_or_options = nil, options = {}, &block)
    if block_given?
      options = content_or_options if content_or_options.is_a?(Hash)
      default_options = {:class => 'btn', "data-toggle" => "modal", "href" => options[:dialog]}.merge(options)

      content_tag :a, nil, default_options, true, &block
    else
      default_options = {:class => 'btn', "data-toggle" => "modal", "href" => options[:dialog]}.merge(options)
      content_tag :a, content_or_options, default_options, true
    end
  end

  def modal_cancel_button content, options = {}
    default_options = {:class => "btn bootstrap-modal-cancel-button"}

    content_tag_string "a", content, default_options.merge(options)
  end

  def render_breadcrumbs(divider = '/')
    render :partial => 'twitter-bootstrap/breadcrumbs', :locals => { :divider => divider }
  end
end
