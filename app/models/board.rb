class Board < ApplicationRecord
belongs_to :user 

 validates :title, length: { minimum: 5 }
 validates :description, length: { minimum: 5 }
 validates :user_id, presence: true    

end
