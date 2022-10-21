module ReactHelper
  class ReactComponent
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def render(props = {}, options = {})
      tag = options.delete(:tag) || :div
      data = { data: { 'react-class' => @name, 'react-props' => props.to_json } }

      content_tag(tag, nil, options.deep_merge(data))
    end
  end

  def react_component(component_name, props = {}, options = {})
    ReactHelper::ReactComponent.new(component_name).render(props, options)
  end
end