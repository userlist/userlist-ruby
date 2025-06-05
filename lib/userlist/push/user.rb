module Userlist
  class Push
    class User < Resource
      include Operations::Push
      include Operations::Delete

      has_many :relationships, type: 'Userlist::Push::Relationship', inverse: :user
      has_many :companies, type: 'Userlist::Push::Company'
      has_one  :company, type: 'Userlist::Push::Company'
    end
  end
end
