module FriendlyTitleHelper

  include FormatDate

  def self.included(base)
    base.extend FriendlyId
    base.friendly_id :slug_candidates, use: :slugged
#    base.send :include, InstanceMethods
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :title,
      [:title, :url_identifier],
      [:title, ->{ start_date_to_append }],
      [:title, ->{ rand 1000 }]
    ]
  end

  def start_date_to_append
    "-#{month_day_full_year(start_date)}"
  end

end
