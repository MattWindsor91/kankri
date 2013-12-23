require 'kankri/exceptions'

module Kankri
  # Wrapper around a set of privileges a client has
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
      PrivilegeChecker.new(target, privilege, @privileges).check?
    end

    private

    # @api private
    # @return [Hash]  The symbolised privileges set.
    def symbolise_privileges(privileges)
      Hash[
        privileges.map do |key, key_privs|
          [key.to_sym, symbolise_privilege_list(key_privs)]
        end
      ]
    end

    # @api private
    # @return [Object]  The symbolised privilege list.
    def symbolise_privilege_list(privlist)
      privlist.is_a?(Array) ? privlist.map(&:to_sym) : privlist.to_sym
    end
  end

  # A method object for checking privileges.
  class PrivilegeChecker
    # @api public
    def initialize(target, requisite, privileges)
      @target = target.intern
      @requisite = requisite.intern
      @privileges = privileges
    end

    # @api public
    # @return [Boolean]  True if the privilege is held by the privilege set
    #   for the target; false otherwise.
    def check?
      target_in_privileges? && has_privilege?
    end


    private

    # @api private
    # @return [Boolean]  True if the target key is in the privileges set.
    def target_in_privileges?
      @privileges.key?(@target)
    end

    # @api private
    # @return [Boolean]  True if the privilege is held by the privilege set
    #   for the target; false otherwise.
    def has_privilege?
      has_all? || has_direct?
    end

    # @api private
    # @return [Boolean]  True if this privilege set has all privileges for a
    #   target; false otherwise.
    def has_all?
      @privileges.fetch(@target) == :all
    end

    # @api private
    # @return [Boolean]  True if this privilege set explicitly has a certain
    #   privilege for a certain target; false otherwise.
    def has_direct?
      @privileges.fetch(@target).include?(@requisite)
    end
  end
end
