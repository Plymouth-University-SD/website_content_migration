class Assignment < ActiveRecord::Base
  belongs_to :uopuser
  belongs_to :url
  validates :uopuser_id, presence: true
  validates :url_id, presence: true, uniqueness: true
end