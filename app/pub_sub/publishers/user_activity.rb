module Publishers
  class UserActivity
    include Publisher

    self.pub_sub_namespace = 'activities/users'
  end
end
