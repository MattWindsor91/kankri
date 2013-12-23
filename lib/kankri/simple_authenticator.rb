require 'kankri'

module Kankri
  # An object that takes in a user hash and authenticates users
  #
  # This object holds user data in memory, including passwords.  It is thus
  # not secure for mission-critical applications.
  class SimpleAuthenticator
    # Makes hashing functions for users based on SHA256.
    # @api public
    def self.sha256_hasher(usernames)
      digest_hasher(usernames, Digest::SHA256)
    end

    # Makes hashing functions for users based on a Digest implementation.
    # @api public
    def self.digest_hasher(usernames, hasher)
      Hash[
        usernames.map do |username|
          salt = SecureRandom.random_bytes
          [username, ->(password) { hasher.digest(password + salt) } ]
        end
      ]
    end

    # @api public
    def initialize(users, hash_maker = nil)
      hash_maker ||= self.class.method(:sha256_hasher)
      @users = users

      @hashers = hash_maker.call(@users.keys)
      @passwords = passwords
      @privilege_sets = privilege_sets
    end

    # @api public
    def authenticate(username, password)
      auth_fail unless auth_ok?(username.intern, password.to_s)
      privileges_for(username.intern)
    end

    private

    # @api private
    def privileges_for(username)
      @privilege_sets[username]
    end

    # Creates a hash mapping username symbols to their password strings
    # @api private
    def passwords
      transform_users do |name, entry|
        plaintext = entry.fetch(:password).to_s
        @hashers.fetch(name).call(plaintext)
      end
    end

    # Creates a hash mapping username symbols to their privilege sets
    # @api private
    def privilege_sets
      transform_users { |_, entry| PrivilegeSet.new(entry.fetch(:privileges)) }
    end

    # @api private
    def transform_users
      Hash[@users.map { |name, entry| [name.intern, (yield name, entry)] }]
    end

    # @api private
    def auth_fail
      fail(Kankri::AuthenticationFailure)
    end

    # @api private
    def auth_ok?(username, password)
      username_present?(username) && password_ok?(username, password)
    end

    # @api private
    def username_present?(username)
      @hashers.key?(username) && @passwords.key?(username)
    end

    # @api private
    def password_ok?(username, password)
      hashed_pass = @hashers.fetch(username).call(password)
      PasswordCheck.new(username, hashed_pass, @passwords).ok?
    end
  end
end
