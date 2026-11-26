# frozen_string_literal: true

# The same page as roda_app/views/template.erb: a list of 10 users, with escaped values, to compare rendering.
class TemplateNode < LowNode
  User = Data.define(:id, :name)
  USERS = (1..10).map { |id| User.new(id, "User <#{id}>") }.freeze

  observe '/template'

  def initialize
    @users = USERS
  end

  def render
    <ul>
      <{ for: user in: @users }>
        <li><a href="/users/{user.id}">{user.name}</a></li>
      <{ :for }>
    </ul>
  end
end
