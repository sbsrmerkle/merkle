require 'lib/merkle_utils'

RSpec.describe MerkleUtils do
  subject { described_class }

  describe ':tree_height' do
    it { expect { subject.tree_height(-1) }.to raise_error ArgumentError }

    it { expect(subject.tree_height(0)).to eq 0 }
    it { expect(subject.tree_height(1)).to eq 1 }
    it { expect(subject.tree_height(2)).to eq 2 }
    it { expect(subject.tree_height(3)).to eq 3 }
    it { expect(subject.tree_height(4)).to eq 3 }
    it { expect(subject.tree_height(5)).to eq 4 }
    it { expect(subject.tree_height(6)).to eq 4 }
    it { expect(subject.tree_height(7)).to eq 4 }
    it { expect(subject.tree_height(8)).to eq 4 }
    it { expect(subject.tree_height(9)).to eq 5 }
  end

  describe ':sibling_index' do
    it { expect { subject.sibling_index(-1) }.to raise_error ArgumentError }

    it { expect(subject.sibling_index(0)).to eq 1 }
    it { expect(subject.sibling_index(1)).to eq 0 }
    it { expect(subject.sibling_index(2)).to eq 3 }
    it { expect(subject.sibling_index(3)).to eq 2 }
    it { expect(subject.sibling_index(4)).to eq 5 }
    it { expect(subject.sibling_index(5)).to eq 4 }
  end

  describe ':parent_index' do
    it { expect { subject.parent_index(-1) }.to raise_error ArgumentError }

    it { expect(subject.parent_index(0)).to eq 0 }
    it { expect(subject.parent_index(1)).to eq 0 }
    it { expect(subject.parent_index(2)).to eq 1 }
    it { expect(subject.parent_index(3)).to eq 1 }
    it { expect(subject.parent_index(4)).to eq 2 }
    it { expect(subject.parent_index(5)).to eq 2 }
  end

  describe ':nodes_needed_to_verify' do
    it 'raises an error if the blocks count is less than 0' do
      expect { described_class.nodes_needed_to_verify(0, -1) }.to raise_error \
        ArgumentError, 'blocks_count must be greater than 0'
    end

    it 'raises an error if the block index is greater than the max index of the blocks array' do
      expect { described_class.nodes_needed_to_verify(5, 5) }.to raise_error \
        ArgumentError, 'blocks_index must be between 0 and 4'
    end

    it 'returns an empty list if the blocks count is 1' do
      expect(described_class.nodes_needed_to_verify(0, 1)).to eq []
    end

    context 'when the merkle blocks' do
      #     AB
      #     / \
      #    A   B
      it 'returns the next sibling when we have the first leaf of a tree of height 2' do
        expect(described_class.nodes_needed_to_verify(0, 2)).to eq [[1, 1]]
      end

      it 'returns the first sibling when we have the second leaf of a tree of height 2' do
        expect(described_class.nodes_needed_to_verify(1, 2)).to eq [[1, 0]]
      end
    end

    context 'when the merkle tree has 5 leaves' do
      #                  ABCDE
      #              /           \
      #         ABCD              E.
      #        /     \           /
      #     AB.        CD       E
      #    /  \      /  \      /
      #   A    B    C.    D    E
      context 'when starting with D' do
        it 'returns the list of tuples (level, index) needed to confirm that D is part of the merkle tree' do
          expect(described_class.nodes_needed_to_verify(3, 5)).to eq [
            [3, 2], # C
            [2, 0], # AB
            [1, 1]  # E
          ]
        end
      end

      context 'when starting with E' do
        it 'returns the list of tuples (level, index) needed to confirm that E is part of the merkle tree' do
          expect(described_class.nodes_needed_to_verify(4, 5)).to eq [
            [1, 0]
          ]
        end
      end
    end
  end
end
