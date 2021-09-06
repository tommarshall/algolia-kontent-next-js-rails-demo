class WebhooksController < ApplicationController
  # it’s important to validate the webhook signature to verify Kentico as
  # the source. otherwise, the application would be open to tampering by
  # unauthorised actors
  before_action :validate_kentico_signature, only: [:kentico]

  def kentico
    # kentico will issue a webhook notification for all changes to content items.
    # not all will be relevant to the search data, so the first job is to determine
    # whether this webhook notification is relevant, and stop here if it's not
    return head :no_content if webhook_notification.discardable?

    # loop through any updated articles from the webhook notification
    webhook_notification.articles.each do |id, codename|
      # fetch the content of the updated article
      response = Kentico::FetchContentItem.new(codename).call

      # upsert the article content with active record, which triggers the
      # algolia sync
      Article.find_or_initialize_by(kentico_id: id).update!(response.attributes)
    end

    # respond with success to Kontent
    head :accepted
  end

  private

  def webhook_notification
    @webhook_notification ||= Kentico::WebhookNotification.new(params)
  end

  def validate_kentico_signature
    return if valid_signature?

    render json: {
             errors: [{ detail: 'Invalid signature' }]
           },
           status: :bad_request
  end

  def valid_signature?
    request.headers['X-KC-Signature'] == kentico_signature(request.raw_post)
  end

  # https://github.com/kentico/kontent-webhook-helper-js/blob/60bb8cb96bc530724c67ca87ed97da3b2fd3af12/src/signatures/signature-helper.class.ts
  def kentico_signature(payload)
    algorithm = 'sha256'
    key = ENV.fetch('KENTICO_WEBHOOK_SECRET')
    data = payload.gsub(/[\r\n]+/m, "\r\n")

    Base64.strict_encode64(OpenSSL::HMAC.digest(algorithm, key, data))
  end
end
