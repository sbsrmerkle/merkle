class MerkleHashing
  class << self
    #
    # Hashes a piece of data using Sha256
    #
    # @param [String] value the value to hash
    #
    # @return [String] the Sha256 hash of value
    #
    def hash(value)
      Digest::SHA2.hexdigest(value)
    end
  end
end
