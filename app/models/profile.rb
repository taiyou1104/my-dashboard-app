class Profile < ApplicationRecord
  validates :skills, presence: true
end
