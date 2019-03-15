module ROM
  module LDAP


    #
    # Alias Dereferencing [RFC4512]
    #
    # An indicator as to whether or not alias entries are to be dereferenced.
    #
    # Dereferencing aliases can cause poor search performance for some LDAP directories.
    # Control the extent to which alias dereferencing occurs when searching the directory.


    # Do not dereference aliases in searching or in locating the base object of the search.
    DEREF_NEVER  = 0 # "never"

    # While searching subordinates of the base object, dereference any alias within the search scope.
    DEREF_SEARCH = 1 # "searching"

    # Dereference aliases in locating the base object of the search, but not
    # when searching subordinates of the base object.
    DEREF_FIND   = 2 # "finding"

    # Always dereference aliases both in searching and in locating the base object of the search.
    # is the default behavior.
    DEREF_ALWAYS = 3 # "always"

    # Array of all dereferencing modes
    DEREF_ALL = [DEREF_NEVER, DEREF_SEARCH, DEREF_FIND, DEREF_ALWAYS].freeze



  end
end
