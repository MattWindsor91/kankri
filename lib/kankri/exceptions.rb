module Kankri
  # Exception generated when authentication fails.
  AuthenticationFailure = Class.new(RuntimeError)

  # Exception generated when required privileges are missing.
  InsufficientPrivilegeError = Class.new(RuntimeError)
end
