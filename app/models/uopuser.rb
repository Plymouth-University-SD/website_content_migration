class Uopuser < ActiveRecord::Base
  has_many :assignments
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end