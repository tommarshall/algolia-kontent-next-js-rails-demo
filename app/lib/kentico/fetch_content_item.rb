module Kentico
  class FetchContentItem
    def initialize(codename)
      @codename = codename
    end

    def call
      Kentico::ArticleItemResponse.new(response)
    end

    private

    attr_reader :codename

    def response
      client.item(codename).depth(2).request_latest_content.execute
    end

    def client
      Kentico::Kontent::Delivery::DeliveryClient.new(project_id: project_id)
    end

    def project_id
      ENV.fetch('KENTICO_PROJECT_ID')
    end
  end
end
