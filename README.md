# Kankri

**Kankri** is an exceptionally basic authentication system for Ruby.  It's intended for small projects that don't need database authentication, ACLs or other such things.  It has no runtime dependencies other than Ruby 2.0.

It takes in a hash mapping usernames (strings or symbols) to passwords (strings) as well as a hash mapping *privilege keys* (strings or symbols) to the lists of *privileges* (strings or symbols) the user has on those keys.  It's a bit like ACL... ish.

## Installation

Add this line to your application's Gemfile:

    gem 'kankri'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kankri

## Usage

**Health Warning:** Don't use Kankri for mission-critical authentication.  It's both very simple and also very early in development and, although it has some RSpecs to make sure it isn't doing something stupid, it certainly isn't a replacement for a decent authentication system.

Once kankri is installed, you can get an *authenticator* by doing this:

    require 'kankri'
    auth = Kankri.authenticator_from_hash(
        username: {
            password: 'foo',
            privileges: {
                key_one: :all,  # Grants all privileges
                key_two: [:priv_one, :priv_two, :priv_three],  # Grants some privileges
                key_three: []  # Grants no privileges
            }
        }
    )
                
With an authenticator, you can get the *privilege set* for a user by logging in with **authenticate**:

    privs = auth.authenticate(:username, 'foo')

And then you can check for privileges using that privilege set:

    privs.has?(:key_one, :priv_one)  #=> true
    privs.has?(:key_one, :priv_four)  #=> true
    privs.has?(:key_two, :priv_one)  #=> true
    privs.has?(:key_two, :priv_four)  #=> false
    privs.has?(:key_three, :priv_one)  #=> true
    privs.has?(:key_three, :priv_four)  #=> false

You can also use **#require**, which is like **#has?** but raises a Kankri::InsufficientPrivilegeError on failure and returns nil on success.

You can include Kankri::PrivilegeSubject into a class, which will give it two new methods (**#can?** and **#fail_if_cannot**).  These take a privilege set and a privilege, and call **#has?** and **#require** respectively on that set, passing it the class's **#privilege_key** and the requested privilege.

## Todo

1. Password hashes instead of plaintext
2. More comprehensive testing
3. Better documentation?

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
