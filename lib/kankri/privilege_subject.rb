module Kankri
  # Mixin that allows classes to require privileges from a PrivilegeSet
  #
  # This expects the including class to define a method, 'privilege_key',
  # which identifies the object in the privilege set.
  module PrivilegeSubject
    # Checks whether an operation can proceed on this privilege subject
    def can?(operation, privilege_set)
      privilege_set.has?(operation, privilege_key)
    end

    # Fails if an operation cannot proceed on this model object
    def fail_if_cannot(operation, privilege_set)
      privilege_set.require(operation, privilege_key)
    end
  end
end
