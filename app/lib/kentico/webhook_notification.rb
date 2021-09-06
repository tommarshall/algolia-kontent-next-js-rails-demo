module Kentico
  class WebhookNotification
    def initialize(params)
      @params = params
    end

    def discardable?
      articles.none?
    end

    def articles
      @articles ||= raw_article_items.pluck(:id, :codename)
    end

    private

    attr_reader :params

    def raw_article_items
      items.group_by { |item| item[:type] }['article'] || []
    end

    def items
      params.dig(:data, :items) || []
    end
  end
end
