require 'kankri'

module Kankri
  # An object that takes in a user hash and authenticates users
  #
  # This object holds user data in memory, including passwords.  It is thus
  # not secure for mission-critical applications.
  class SimpleAuthenticator
    # Makes hashing functions for users based on SHA256.
    def self.sha256_hasher(usernames)
      digest_hasher(usernames, Digest::SHA256)
    end

    # Makes hashing functions for users based on a Digest implementation.
    def self.digest_hasher(usernames, hasher)
      Hash[
        usernames.map do |username|
          salt = SecureRandom.random_bytes
          [username, ->(password) { hasher.digest(password + salt) } ]
        end
      ]
    end

    def initialize(users, hash_maker = nil)
      hash_maker ||= self.class.method(:sha256_hasher)
      @users = users

      @hashers = hash_maker.call(@users.keys)
      @passwords = passwords
      @privilege_sets = privilege_sets
    end

    def authenticate(username, password)
      auth_fail unless auth_ok?(username.intern, password.to_s)
      privileges_for(username.intern)
    end

    private

    def privileges_for(username)
      @privilege_sets[username]
    end

    def hashers
      transform_users do |_, _|
        ->(password) { Digest::SHA256.digest(password + salt) }
      end
    end

    # Creates a hash mapping username symbols to their password strings
    def passwords
      transform_users do |name, entry|
        plaintext = entry.fetch(:password).to_s
        @hashers.fetch(name).call(plaintext)
      end
    end

    # Creates a hash mapping username symbols to their privilege sets
    def privilege_sets
      transform_users { |_, entry| PrivilegeSet.new(entry.fetch(:privileges)) }
    end

    def transform_users
      Hash[@users.map { |name, entry| [name.intern, (yield name, entry)] }]
    end

    def auth_fail
      fail(Kankri::AuthenticationFailure)
    end

    def auth_ok?(username, password)
      username_present?(username) && password_ok?(username, password)
    end

    def username_present?(username)
      @hashers.key?(username) && @passwords.key?(username)
    end

    def password_ok?(username, password)
      hashed_pass = @hashers.fetch(username).call(password)
      PasswordCheck.new(username, hashed_pass, @passwords).ok?
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
