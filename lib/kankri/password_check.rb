module Kankri
  # A method object that represents a check on username/password pairs
  class PasswordCheck
    # @api public
    def initialize(username, password, passwords)
      @username = username
      @password = password
      @passwords = passwords
    end

    # @api public
    def ok?
      auth_present? && user_known? && password_match?
    end

    private

    # @api private
    def auth_present?
      username_present? && password_present?
    end

    # @api private
    def username_present?
      !(@username.nil? || @username.empty?)
    end

    # @api private
    def password_present?
      !(@password.nil? || @password.empty?)
    end

    # @api private
    def password_match?
      @passwords.fetch(@username) == @password
    end

    # @api private
    def user_known?
      @passwords.key?(@username)
    end
  end
end
