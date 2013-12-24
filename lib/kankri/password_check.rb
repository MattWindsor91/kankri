module Kankri
  # A method object that represents a check on username/password pairs
  #
  # This is a basic check based on string comparison, failing if either
  # username or password are empty or nil.  If used with a hashing
  # authenticator, the hashing must be done before the password checking.
  # Similarly, PasswordCheck does not convert to or from symbols; the
  # authenticator must do this itself.
  class PasswordCheck
    # Creates a password check instance
    #
    # Passwords may be literal passwords, hashes or any other secret that
    # can be compared by ==.  Any hashing or other processing (such as type
    # conversion) must be done by the Authenticator.
    #
    # @api public
    # @example  Initialises a PasswordCheck.
    #   PasswordCheck.new('alf', 'hunter2', 'alf' => 'hunter2')
    #
    # @param username [Object]  The username; this is typically a Symbol or a
    #   String.
    # @param password [String]  The password to check against the passwords
    #   database.
    # @param passwords [Hash]  The hash mapping usernames to their passwords.
    def initialize(username, password, passwords)
      @username = username
      @password = password
      @passwords = passwords
    end

    # Checks to see if the authentication credentials are correct
    #
    # @api public
    # @example  Perform a successful authentication check.
    #   checker.ok?
    #   #=> true
    # @example  Perform an unsuccessful authentication check.
    #   checker.ok?
    #   #=> false
    #
    # @return [Boolean]  True if the password matches; false otherwise.
    def ok?
      auth_present? && user_known? && password_match?
    end

    # Creates and runs a password check
    #
    # @api public
    # @example  Check a correct password.
    #   PasswordCheck.check('alf', 'hunter2', 'alf' => 'hunter2')
    #   #=> true
    # @example  Check an incorrect password.
    #   PasswordCheck.check('alf', 'nope', 'alf' => 'hunter2')
    #   #=> false
    #
    # @param (see #initialize)
    #
    # @return (see #ok?)
    def self.check(*args)
      PasswordCheck.new(*args).ok?
    end

    private

    # Checks to see if the authentication credentials are present and non-empty
    #
    # @api private
    #
    # @return [Boolean]  True if the credentials are present; false otherwise.
    def auth_present?
      username_present? && password_present?
    end

    # Checks to see if the username is present and non-empty
    #
    # @api private
    #
    # @return [Boolean]  True if the username is present; false otherwise.
    def username_present?
      !(@username.nil? || @username.empty?)
    end

    # Checks to see if the password is present and non-empty
    #
    # @api private
    #
    # @return [Boolean]  True if the password is present; false otherwise.
    def password_present?
      !(@password.nil? || @password.empty?)
    end

    # Checks to see if the user has a known password
    #
    # @api private
    #
    # @return [Boolean]  True if the user's password is known; false otherwise.
    def user_known?
      @passwords.key?(@username)
    end

    # Checks to see if the password matches that on record for the user
    #
    # @api private
    #
    # @return [Boolean]  True if the password matches; false otherwise.
    def password_match?
      @passwords.fetch(@username) == @password
    end
  end
end
