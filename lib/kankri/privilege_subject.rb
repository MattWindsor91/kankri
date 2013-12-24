module Kankri
  # Mixin that allows classes to require privileges from a PrivilegeSet
  #
  # This expects the including class to define a method, 'privilege_key',
  # which identifies the object in the privilege set.
  module PrivilegeSubject
    # Checks whether a privilege is granted for this object
    #
    # This looks in the privilege set under the key returned by #privilege_key.
    #
    # @api public
    # @example  Checks for a privilege that is in the set for this object.
    #   subject.can?(:get, privilege_set)
    #   #=> true
    #
    # @example  Checks for a privilege that is not in the set for this object.
    #   subject.can?(:get, privilege_set)
    #   #=> false
    #
    # @param operation [Object]  The String or Symbol identifying the operation
    #   for which privileges are required.
    #
    # @param privilege_set [PrivilegeSet]  The set of privileges that must
    #   contain the required privilege.
    #
    # @return [Boolean]  True if the privileges are sufficient; false
    #   otherwise.
    def can?(operation, privilege_set)
      privilege_set.has?(operation, privilege_key)
    end

    # Raises an exception if a privilege is not granted for this object
    #
    # This looks in the privilege set under the key returned by #privilege_key.
    #
    # @api public
    # @example  Requires a privilege to continue.
    #   subject.require(:get, privilege_set)
    #
    # @param (see #can?)
    #
    # @return [void]
    def fail_if_cannot(operation, privilege_set)
      privilege_set.require(operation, privilege_key)
    end
  end
end
