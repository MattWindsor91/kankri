module Kankri
  # A method object that represents a check on username/password pairs
  #
  # This is a basic check based on string comparison, failing if either
  # username or password are empty or nil.  If used with a hashing
  # authenticator, the hashing must be done before the password checking.
  class PasswordCheck
    # @api public
    def initialize(username, password, passwords)
      @username = username
      @password = password
      @passwords = passwords
    end

    # @api public
    # @return [Boolean]  True if the password matches; false otherwise.
    def ok?
      auth_present? && user_known? && password_match?
    end

    private

    # @api private
    # @return [Boolean]  True if the credentials are present; false otherwise.
    def auth_present?
      username_present? && password_present?
    end

    # @api private
    # @return [Boolean]  True if the username is present; false otherwise.
    def username_present?
      !(@username.nil? || @username.empty?)
    end

    # @api private
    # @return [Boolean]  True if the password is present; false otherwise.
    def password_present?
      !(@password.nil? || @password.empty?)
    end

    # @api private
    # @return [Boolean]  True if the user's password is known; false otherwise.
    def user_known?
      @passwords.key?(@username)
    end

    # @api private
    # @return [Boolean]  True if the password matches; false otherwise.
    def password_match?
      @passwords.fetch(@username) == @password
    end
  end
end
