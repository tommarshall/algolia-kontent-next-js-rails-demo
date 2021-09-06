class Article < ApplicationRecord
  include AlgoliaSearch

  algoliasearch if: :indexable? do
    # the list of attributes to include in the Algolia record
    attributes :title,
               :body,
               :tags,
               :author,
               :published_at,
               :image,
               :estimated_reading_time_mins,
               :estimated_reading_time_human_readable,
               :url_slug,
               :kentico_id

    # defines the attributes to match search terms against.
    # list them by order of importance.
    searchableAttributes %w[title tags author body]

    # attributes to filter results by
    attributesForFaceting %w[author tags estimated_reading_time_human_readable]

    # defines the ranking criteria used to compare two matching records in case
    # their text-relevance is equal. It should reflect your record popularity.
    customRanking ['desc(published_at_unix_timestamp)']
  end

  # only include articles that are published within Kontent
  def indexable?
    published?
  end

  # group the estimated reading times into a human readable set for friendlier
  # filtering, rather than having a filter option for each integer value
  def estimated_reading_time_human_readable
    case estimated_reading_time_mins
    when 0...2
      'Less than 2 minutes'
    when 2...6
      '2 to 6 minutes'
    when 6...10
      '6 to 10 minutes'
    when (10..)
      '10+ minutes'
    end
  end

  # convert the date attribute to an integer for sorting
  def published_at_unix_timestamp
    published_at.to_time(:utc).to_i
  end
end
