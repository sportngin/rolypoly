module Rolypoly
  class ResourceIndexQueryBuilder
    include IndexRoleDSL

    attr_reader :query, :user

    allow(:third_north).to_all
    allow(:org_admin).on(:organization).to_access(:org_id)
    allow(:tournament_director).on(:organization).to_access(:org_id)

    def initialize(query, user)
      @query = query
      @user = user
    end

    private def current_user_roles
      user.role_assignments
    end
  end
end
