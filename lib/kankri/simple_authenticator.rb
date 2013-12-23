require 'kankri'

module Kankri
  # An object that takes in a user hash and authenticates users
  #
  # This object holds user data in memory, including passwords.  It is thus
  # not secure for mission-critical applications.
  class SimpleAuthenticator
    def initialize(users)
      @users = users

      @passwords = passwords
      @privilege_sets = privilege_sets
    end

    def authenticate(username, password)
      auth_fail unless auth_ok?(username.intern, password.to_s)
      privileges_for(username)
    end

    private

    def privileges_for(username)
      @privilege_sets[username.intern]
    end

    # Creates a hash mapping username symbols to their password strings
    def passwords
      transform_users { |user| user[:password].to_s }
    end

    # Creates a hash mapping username symbols to their privilege sets
    def privilege_sets
      transform_users { |user| PrivilegeSet.new(user[:privileges]) }
    end

    def transform_users
      Hash.new[@users.map { |name, entry| [name.intern, (yield entry)] }]
    end

    def auth_fail
      fail(Kankri::AuthenticationFailure)
    end

    def auth_ok?(username, password)
      PasswordCheck.new(username, password, @passwords).ok?
    end
  end

  # A method object that represents a check on username/password pairs
  class PasswordCheck
    def initialize(username, password, passwords)
      @username = username
      @password = password
      @passwords = passwords
    end

    def ok?
      auth_present? && password_match?
    end

    def auth_present?
      username_present? && password_present?
    end

    def username_present?
      !(@username.nil? || @username.empty?)
    end

    def password_present?
      !(@password.nil? || @password.empty?)
    end

    def password_match?
      @passwords[@username] == @password
    end
  end
end
