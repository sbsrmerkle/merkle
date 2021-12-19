class TestHashing
  class << self
    #
    # Hashes a piece of data using by converting it to a String
    # and upper casing its alphabetical characters.
    #
    # Useful when wanting to easily visualize what a Merkle tree
    # looks like using alphabetical values for the data blocks.
    #
    # @param [String] value the value to hash
    #
    # @return [String] the Sha256 hash of value
    #
    def hash(value)
      String(value).upcase
    end
  end
end
