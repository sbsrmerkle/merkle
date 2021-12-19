require 'lib/test_hashing'

class MerkleUtils
  class << self
    #
    # Calculates the height of the Merkle tree representation
    # of a set of data blocks
    #
    # @param [Integer] blocks_count the number of blocks in the dataset
    #
    # @return [Integer] the height of the Merkle tree
    #
    def tree_height(blocks_count)
      return 0 if blocks_count.zero?
      raise ArgumentError, 'blocks_count must be positive' if blocks_count.negative?

      Math.log2(blocks_count).ceil + 1
    end

    #
    # Calculates the index of the sibling node in a level
    # of a Merkle tree for a given node
    #
    # @param [Integer] index the index of a node on a level of the Merkle tree
    #
    # @return [Integer] the index of the sibling node of the input node
    #
    def sibling_index(index)
      raise ArgumentError, 'index must be positive' if index.negative?

      if index.even?
        index + 1
      else
        index - 1
      end
    end

    #
    # Given a node on a level of the Merkle tree, returns the index
    # of the parent of that node on the level above in the tree
    #
    # @param [Integer] index the index of a node on a level of the Merkle tree
    #
    # @return [Integer] the index of the parent of the input node in the level above in the Merkle tree
    #
    def parent_index(index)
      raise ArgumentError, 'index must be positive' if index.negative?

      index / 2
    end

    #
    # Calculates the minimum amount of data that needs to be
    # included with a given block to be able to verify that it
    # is part of a Merkle tree for which we know the Merkle root
    #
    # @param [Integer] block_index the index of the block that we're trying to verify in the data set
    # @param [Integer] blocks_count the number of blocks in the data set
    #
    # @return [Array[Integer[]]] a list of tuples representing the level and index of nodes of the Merkle tree needed to verify that the integrity of the block
    #
    def nodes_needed_to_verify(block_index, blocks_count)
      raise ArgumentError, 'blocks_count must be greater than 0' if blocks_count <= 0

      unless (blocks_count - block_index).positive?
        raise ArgumentError,
              "blocks_index must be between 0 and #{blocks_count - 1}"
      end

      index = block_index
      nodes_count = blocks_count

      tree_levels = tree_height(blocks_count) - 1

      tree_levels.downto(1).each_with_object([]) do |level, acc|
        idx = sibling_index(index)
        index = parent_index(index)
        acc << [level, idx] if idx < nodes_count
        nodes_count = (nodes_count / 2.0).ceil # number of nodes in the level above
      end
    end

    #
    # Outputs every level of a MerkleTree instance on STDOUT
    #
    # @param [MerkleTree] tree the tree to print
    #
    # @return [NilClass]
    #
    def print(tree)
      (0...tree.height).each do |i|
        puts "#{i}:  #{tree.level(i).join('    ')}"
      end
      puts ''
    end

    #
    # Prints a Merkle representing a list of blocks
    #
    # @param [String[]] blocks an array of data blocks
    #
    # @return [NilClass]
    #
    def debug(blocks)
      print MerkleTree.new(blocks, TestHashing)
    end
  end
end
