require 'kankri'

module Kankri
  # An object that takes in a user hash and authenticates users
  #
  # This object holds user data in memory, including passwords.  It is thus
  # not secure for mission-critical applications.
  class SimpleAuthenticator
    extend Forwardable

    # Makes hashing functions for users based on SHA256
    #
    # @api public
    # @example  Create a set of hashing functions for a given set of usernames
    #   SimpleAuthenticator::sha256_hasher(['alf', 'roy', 'busby'])
    #
    # @param usernames [Array]  A list of usernames to form the keys of the
    #   hashing table.
    #
    # @return [Hash]  A hash mapping usernames to functions that will take
    #   passwords and return their hashed equivalent.
    def self.sha256_hasher(usernames)
      digest_hasher(usernames, Digest::SHA256)
    end

    # Makes hashing functions for users based on a Digest implementation
    #
    # Each hashing function uses a random salt value, which is stored inside
    # the function and unique to the username.
    #
    # @api public
    # @example  Create a set of hashing functions for a given set of usernames
    #   SimpleAuthenticator::digest_hasher(['joe', 'ron'], Digest::SHA256)
    #
    # @param usernames [Array]  A list of usernames to form the keys of the
    #   hashing table.
    # @param hasher [Digest]  A Digest to use when hashing the user passwords
    #
    # @return [Hash]  A hash mapping usernames to functions that will take
    #   passwords and return their hashed equivalent.
    def self.digest_hasher(usernames, hasher)
      Hash[
        usernames.map do |username|
          salt = SecureRandom.random_bytes
          [username, ->(password) { hasher.digest(password + salt) }]
        end
      ]
    end

    # Initialises the SimpleAuthenticator
    #
    # @api public
    # @example  Initialises the SimpleAuthenticator with a user hash.
    #   SimpleAuthenticator.new(
    #     admin: {
    #       password: 'hunter2',
    #       privileges: {
    #         foo: 'all',
    #         bar: ['abc', 'def', 'ghi'],
    #         baz: []
    #       }
    #     }
    #   )
    # @example  Initialises the SimpleAuthenticator with a custom hasher.
    #   SimpleAuthenticator.new(
    #     { admin: {
    #         password: 'hunter2',
    #         privileges: {
    #           foo: 'all',
    #           bar: ['abc', 'def', 'ghi'],
    #           baz: []
    #         }
    #       }
    #     }, hasher
    #   )
    #
    # @param users [String]  A hash mapping usernames (which may be Strings or
    #   Symbols) to hashes containing a mapping from :password to the user's
    #   password, and from :privileges to a hash mapping privilege keys to
    #   privilege lists.
    # @param hash_maker [Object]  A callable that takes a list of usernames
    #   and returns a hash mapping the usernames to functions that hash
    #   passwords for those users.  If nil, a sensible default hasher will be
    #   used.
    def initialize(users, hash_maker = nil)
      hash_maker ||= self.class.method(:sha256_hasher)
      @users = users

      @hashers = hash_maker.call(@users.keys)
      @passwords = passwords
      @privilege_sets = privilege_sets
    end

    # Attempts to authenticate with the given username and password
    #
    # This will fail with an AuthenticationFailure exception if the credentials
    # are invalid.
    #
    # @api public
    # @example  Authenticates with a String username and password.
    #   auth.authenticate('joe_bloggs', 'hunter2')
    # @example  Authenticates with a Symbol username and String password.
    #   auth.authenticate(:joe_bloggs, 'hunter2')
    #
    # @param username [Object]  The candidate username; this may be either a
    #   String or a Symbol, and will be normalised to a Symbol.
    # @param username [Object]  The candidate username; this may be either a
    #   String or a Symbol, and will be normalised to a String.
    #
    # @return [PrivilegeSet]  The privilege set for the username
    def authenticate(username, password)
      auth_fail unless auth_ok?(username.intern, password.to_s)
      privileges_for(username.intern)
    end

    private

    # Returns the privilege set for the given username
    #
    # @api private
    #
    # @param username [Object]  The username whose privilege set is sought.
    #
    # @return [PrivilegeSet]  The privilege set for the username
    def_delegator :@privilege_sets, :fetch, :privileges_for

    # Creates a hash mapping username symbols to their password strings
    #
    # @api private
    #
    # @return [Hash]  A hash mapping usernames to passwords
    def passwords
      transform_users do |name, entry|
        plaintext = entry.fetch(:password).to_s
        @hashers.fetch(name).call(plaintext)
      end
    end

    # Creates a hash mapping username symbols to their privilege sets
    #
    # @api private
    #
    # @return [Hash]  A hash mapping usernames to privilege sets
    def privilege_sets
      transform_users { |_, entry| PrivilegeSet.new(entry.fetch(:privileges)) }
    end

    # Creates a new Hash by modifying the entries of the user hash
    #
    # @api private
    #
    # @yieldparam name [Object]  The username.
    # @yieldparam entry [Hash]  The user entry.
    #
    # @return [Hash]  The hash mapping usernames to the yielded values.
    def transform_users
      Hash[@users.map { |name, entry| [name.intern, (yield name, entry)] }]
    end

    # Fails with an AuthenticationFailure exception
    #
    # @api private
    #
    # @return [void]
    def auth_fail
      fail(Kankri::AuthenticationFailure)
    end

    # Checks to see if given authentication credentials are OK
    #
    # @api private
    #
    # @param username [Object]  The username of the authentication attempt.
    # @param password [Object]  The password of the authentication attempt.
    #
    # @return [Boolean]  True if the authentication attempt fails; false
    #   otherwise.
    def auth_ok?(username, password)
      username_present?(username) && password_ok?(username, password)
    end

    # Checks to see if the username is in the system
    #
    # @api private
    #
    # @param username [Object]  The username of the authentication attempt.
    #
    # @return [Boolean]  True if the username exists in the authenticator;
    #  false otherwise.
    def username_present?(username)
      @hashers.key?(username) && @passwords.key?(username)
    end

    # Checks the password to see if it is correct for this username
    #
    # @api private
    #
    # @param username [Object]  The username of the authentication attempt.
    # @param password [Object]  The password of the authentication attempt.
    #
    # @return [Boolean]  True if the password is correct; false otherwise.
    def password_ok?(username, password)
      hashed_pass = hashed_password(username, password)
      PasswordCheck.check(username, hashed_pass, @passwords)
    end

    # Applies the user's hashing function to the candidate password
    #
    # @api private
    #
    # @param username [Object]  The username of the authentication attempt.
    # @param password [Object]  The password of the authentication attempt.
    #
    # @return [Object]  The hashed password.
    def hashed_password(username, password)
      @hashers.fetch(username).call(password)
    end
  end
end
