module Kankri
  # A method object for checking privileges
  #
  # A PrivilegeChecker takes the target privilege key and required privilege,
  # as well as the hash mapping privilege keys to their
  class PrivilegeChecker
    # Creates a PrivilegeChecker
    #
    # @api public
    # @example  Initialise a passing privilege check.
    #   PrivilegeChecker.new(:foo, :bar, foo: [:bar])
    # @example  Initialise a failing privilege check.
    #   PrivilegeChecker.new(:foo, :bar, foo: [])
    #
    # @param target [Symbol]  The privilege key that is the target of this
    #   privilege check.
    # @param requisite [Symbol]  The privilege required under the privilege
    #   key.
    # @param privileges [Hash]  A hash mapping privilege keys to their
    #   privilege lists.
    def initialize(target, requisite, privileges)
      @target = target
      @requisite = requisite
      @privileges = privileges
    end

    # Runs the privilege checker and checks the privilege
    #
    # @api public
    # @example  Runs a passing privilege checker.
    #   checker.run
    #   #=> true
    # @example  Runs a failing privilege checker.
    #   checker.run
    #   #=> false
    #
    # @return [Boolean]  True if the privilege is held by the privilege set
    #   for the target; false otherwise.
    def valid?
      target_in_privileges? && has_privilege?
    end

    # Creates and runs a privilege checker
    #
    # @api public
    # @example  Do a passing privilege check.
    #   PrivilegeChecker.check(:foo, :bar, foo: [:bar])
    #   #=> true
    #
    # @example  Do a failing privilege check.
    #   PrivilegeChecker.check(:foo, :bar, foo: [])
    #   #=> false
    #
    # @param (see #initialize)
    #
    # @return (see #valid?)
    def self.check(*args)
      new(*args).valid?
    end

    private

    # Checks to see if the target is in the privileges set
    #
    # @api private
    #
    # @return [Boolean]  True if the target key is in the privileges set;
    #   false otherwise.
    def target_in_privileges?
      @privileges.key?(@target)
    end

    # Checks to see if the privilege request is satisfied for the target
    #
    # This assumes that the target exists in the privilege list.
    #
    # @api private
    #
    # @return [Boolean]  True if the privilege is held by the privilege set
    #   for the target; false otherwise.
    def has_privilege?
      has_all? || has_direct?
    end

    # Checks to see if the privilege request is satisfied by an 'all' clause
    #
    # @api private
    # @return [Boolean]  True if this privilege set has all privileges for a
    #   target; false otherwise.
    def has_all?
      @privileges.fetch(@target) == :all
    end

    # Checks to see if the privilege request is satisfied directly
    #
    # @api private
    #
    # @return [Boolean]  True if this privilege set explicitly has a certain
    #   privilege for a certain target; false otherwise.
    def has_direct?
      @privileges.fetch(@target).include?(@requisite)
    end
  end
end
