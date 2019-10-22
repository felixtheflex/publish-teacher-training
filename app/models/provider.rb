class Provider < Base
  belongs_to :recruitment_cycle, param: :recruitment_cycle_year
  has_many :courses, param: :course_code
  has_many :sites

  self.primary_key = :provider_code

  def publish
    post_request("/publish")
  end

  def publishable?
    post_request("/publishable")
  end

  def course_count
    relationships.courses[:meta][:count]
  end

  def full_address
    [address1, address2, address3, address4, postcode].select(&:present?).join("<br> ").html_safe
  end

  def rolled_over?
    Settings.rollover
  end

  def has_unpublished_changes?
    content_status == "published_with_unpublished_changes"
  end

  def is_published?
    content_status == "published"
  end

  def admin_contact_name
    admin_contact['name'] if admin_contact.present?
  end

  def admin_contact_email
    admin_contact['email']
  end

  def admin_contact_telephone
    admin_contact['telephone']
  end

  # def admin_contact_name=(value)
  #   admin_contact['name'] = value
  # end
  #
  # def admin_contact_email=(value)
  #   admin_contact['email'] = value
  # end
  #
  # def telephone=(value)
  #   admin_contact['telephone'] = value
  # end

private

  def post_base_url
    "#{Provider.site}#{Provider.path}/%<provider_code>s" % path_attributes
  end
end
