module Kankri
  # A method object that represents a check on username/password pairs
  class PasswordCheck
    def initialize(username, password, passwords)
      @username = username
      @password = password
      @passwords = passwords
    end

    def ok?
      auth_present? && user_known? && password_match?
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
      @passwords.fetch(@username) == @password
    end

    def user_known?
      @passwords.key?(@username)
    end
  end
end
