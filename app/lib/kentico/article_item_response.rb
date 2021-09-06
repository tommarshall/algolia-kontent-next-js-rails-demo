module Kentico
  class ArticleItemResponse
    def initialize(response)
      @response = response
    end

    def attributes
      case response.http_code
      when 200
        published_attributes
      when 404
        unpublished_attributes
      else
        raise response.to_s
      end
    end

    private

    attr_reader :response

    def published_attributes
      {
        title: item.elements.title.value,
        body: item.elements.body.value,
        tags: tags,
        author: author,
        published_at: Date.parse(item.elements.published_date.value),
        image: item.elements.primary_image.value.first.url,
        estimated_reading_time_mins:
          item.elements.estimated_reading_time_mins.value,
        url_slug: item.elements.url_slug.value,
        kentico_id: item.system.id,
        published: true
      }
    end

    def unpublished_attributes
      { published: false }
    end

    def item
      @item ||= response.item
    end

    def tags
      item.get_links(:tags).map { |tag| tag.elements.name.value }
    end

    def author
      item.get_links(:author).first.elements.name.value
    end
  end
end
