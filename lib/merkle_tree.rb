require 'digest'
require 'lib/merkle_utils'
require 'lib/merkle_hashing'

class MerkleTree
  attr_reader :height

  #
  # Constructor for the MerkleTree class
  #
  # @param [String[]] blocks a list of data blocks
  # @param [MerkleHashing | TestHashing] hashing Hashing algorithm to build the Merkle tree,
  #                                              used to inject different algorithms.
  #                                              Defaults to SHA256
  #
  def initialize(blocks, hashing = MerkleHashing)
    raise ArgumentError, 'the input should have at least one element' if blocks.empty?

    @hashing = hashing || MerkleHashing

    @height = MerkleUtils.tree_height(blocks.size)
    @tree = build_tree(blocks)
  end

  #
  # Returns the Merkle root of the Merkle tree
  #
  # @return [String] value of the Merkle root
  #
  def root
    level(0).first
  end

  #
  # Returns the nodes on a given level of the Merkle tree
  #
  # @param [Integer] index requested level of the tree. 0 indexed, root = 0
  #
  # @return [String[]] the nodes of the requested level of the Merkle tree, ordered
  #
  def level(index)
    raise ArgumentError, "index must be between 0 and #{height - 1}" unless (0...height).include?(index)

    tree[index]
  end

  #
  # Calculate the index of the parent of the Merkle leaf of a given
  # data block
  #
  # @param [Integer] block_index index of the block
  #
  # @return [String] value of the parent node of the Merkle leaf of the block
  #                  returns `nil` for a single block tree
  #                  return `nil` if the block does not exist
  #
  def parent_node(block_index)
    return nil if height == 1
    return nil if block_index >= level(height - 1).size

    level(height - 2)[MerkleUtils.parent_index(block_index)]
  end

  #
  # Returns the vlaue of the sibling of a node on a level of the Merkle tree
  #
  # @param [Integer] level level of the Merkle tree
  # @param [Integer] index index of the node
  #
  # @return [String | NilClass] value of the sibling node
  #                             returns `nil` if the node doesn't have a sibling
  #
  def sibling_node(level_index, index)
    level_values = level(level_index)

    return nil if index >= level_values.size

    level_values[MerkleUtils.sibling_index(index)]
  end

  #
  # Verifies the validity of a given data block leveraging the
  # access to the full Merkle tree of the dataset.
  #
  # This is the implementation for the Additional Question #1
  #
  # @param [String] block_data the data block to verify
  # @param [Integer] block_index the index of the block in the data set
  #
  # @return [Boolean] true if the data block is valid, false otherwise
  #
  def block_valid?(block_data, block_index)
    block_hash = hash(block_data)
    sigling_hash = sibling_node(height - 1, block_index)
    parent_hash = parent_node(block_index)

    if block_index.even?
      hash(concat(block_hash, sigling_hash)) == parent_hash
    else
      hash(concat(sigling_hash, block_hash)) == parent_hash
    end
  end

  #
  # Calculates the minimum amount of Merkle hashes that need to be included with a block
  # for being able to verify that the block is part of a Merkle tree for which only the
  # Merkle root is known
  #
  # @param [Integer] block_index index of the block in the dataset
  #
  # @return [String[]] list of hashes needed to compute the Merkle root along with the block data
  #
  def hashes_needed_to_verify(block_index)
    MerkleUtils.nodes_needed_to_verify(block_index, level(height - 1).size).map do |height, index|
      level(height)[index]
    end
  end

  private

  attr_reader :tree

  def hash(value)
    @hashing.hash(value)
  end

  def concat(value_a, value_b)
    return value_a if value_b.nil?

    value_a + value_b
  end

  def build_tree(blocks)
    result = Array.new(height)
    result[-1] = blocks.map(&method(:hash))

    (height - 1).downto(1).each do |index|
      current_level = result[index]
      result[index - 1] = current_level.each_slice(2).map do |(a, b)|
        if b.nil?
          a
        else
          hash(concat(a, b))
        end
      end
    end

    result
  end
end
