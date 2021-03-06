## Generic for all request type objects
module Requestable
  extend ActiveSupport::Concern

  included do
    belongs_to :employee_type
    belongs_to :request_type
    belongs_to :department
    belongs_to :unit
    belongs_to :review_status
    has_one :division, through: :department, autosave: false

    validates :employee_type, presence: true
    validates :position_title, presence: true
    validates :request_type, presence: true
    validates :department_id, presence: true
    validates_with RequestDepartmentValidator

    validates_with RequestEmployeeTypeValidator, valid_employee_category_code: self::VALID_EMPLOYEE_CATEGORY_CODE
    validate :allowed_request_type

    after_initialize :init

    # Sets the review status to default
    def init
      return if has_attribute?(:review_status_id) && review_status_id
      self.review_status = ReviewStatus.find_by(code: 'UnderReview')
    end
  end

  class_methods do
  end

  # Validates the request type
  def allowed_request_type
    return if self.class::VALID_REQUEST_TYPE_CODES.include?(request_type.try(:code))
    errors.add(:request_type, 'Not an allowed request type for this request.')
  end

  # method to call the fields expressed in .fields
  def call_field(field)
    field.to_s.split('__').inject(self) { |a, e| a.send(e) unless a.nil? }
  end
end
