require 'kankri/exceptions'
require 'kankri/privilege_check'

module Kankri
  # Wrapper around a set of privileges a user has
  #
  # The PrivilegeSet is the return value of an Authenticator, and represents
  # the level of privilege the
  class PrivilegeSet
    # Initialises a privilege set.
    #
    # @api public
    # @example Create a privilege set with no privileges.
    #   PrivilegeSet.new({})
    # @example Create a privilege set with some privileges.
    #   PrivilegeSet.new({channel_set: [:get, :put]})
    def initialize(privileges)
      @privileges = symbolise_privileges(privileges)
    end

    # Requires a certain privilege on a certain target
    # @api public
    # @return [void]
    def require(target, privilege)
      fail(InsufficientPrivilegeError) unless has?(target, privilege)
    end

    # Checks to see if a certain privilege exists on a given target
    #
    # @api public
    # @example Check your privilege.
    #   privs.has?(:channel, :put)
    #   #=> false
    #
    # @param target [Symbol]  The handler target the privilege is for.
    # @param privilege [Symbol]  The privilege (one of :get, :put, :post or
    #   :delete).
    #
    # @return [Boolean]  True if the privileges are sufficient; false
    #   otherwise.
    def has?(privilege, target)
      PrivilegeChecker.check(target.to_sym, privilege.to_sym, @privileges)
    end

    private

    # Converts the keys and values in a privileges hash into Symbols
    #
    # @api private
    #
    # @param privileges [Hash]  The privilege hash to symbolise.
    #
    # @return [Hash]  The symbolised privileges set.
    def symbolise_privileges(privileges)
      Hash[
        privileges.map do |key, key_privs|
          [key.to_sym, symbolise_privilege_list(key_privs)]
        end
      ]
    end

    # Converts a privilege list to Symbols
    #
    # If the privilege list is the String 'all', it will become :all.
    # If it is an actual list, each privilege will be converted to a Symbol.
    #
    # @api private
    #
    # @return [Object]  The symbolised privilege list.
    def symbolise_privilege_list(privlist)
      privlist.is_a?(Array) ? privlist.map(&:to_sym) : privlist.to_sym
    end
  end
end
