require 'kankri/password_check'
require 'kankri/privilege_set'
require 'kankri/privilege_subject'
require 'kankri/simple_authenticator'
require 'kankri/version'

# Main module for Kankri
#
# Kankri is a library for quickly setting up basic authentication with object-
# action privileges.
#
# It's intended to be used in projects which need a simple auth system with no
# run-time requirements and little set-up.  It isn't intended for mission
# critical security.
module Kankri
  # Creates an authenticator object from a hash
  #
  # The hash should map username strings to hashes with the following Symbol
  # keys:
  #
  # - password: The plain-text password for the user.
  # - privileges: A hash mapping String or Symbol 'privilege keys' to either
  #     the String 'all' or Symbol :all, meaning the user has all privileges
  #     for that key, or a list of String or Symbol privileges the user has for
  #     that key.
  #
  # @api public
  # @example  Create an authenticator from a hash of users.
  #   Kankri.authenticator_From_hash(
  #     admin: {
  #       password: 'hunter2',
  #       privileges: {
  #         foo: 'all',
  #         bar: ['abc', 'def', 'ghi'],
  #         baz: []
  #       }
  #     }
  #   )
  #
  # @return [Object]  An authenticator for the given hash.
  def self.authenticator_from_hash(hash)
    SimpleAuthenticator.new(hash)
  end
end
