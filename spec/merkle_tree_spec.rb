require 'rubygems'
require 'lib/merkle_tree'
require 'lib/test_hashing'

RSpec.describe MerkleTree do
  let(:blocks) { [1, 2, 4, 5] }
  let(:hash_function) { ->(a, b) { a + b } }
  subject(:merkle_tree) { described_class.new(blocks, TestHashing) }

  describe ':new' do
    describe 'exceptions' do
      it 'raises an error if the blocks array is empty' do
        expect { described_class.new([]) }.to raise_error ArgumentError, 'the input should have at least one element'
      end
    end
  end

  describe '#root' do
    context 'one block' do
      let(:blocks) { ['a'] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.root).to eq 'A'
      end
    end

    context 'two blocks' do
      let(:blocks) { %w[a b] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.root).to eq 'AB'
      end
    end

    context 'Merkle tree with a leaf that does not have a sibling' do
      let(:blocks) { %w[a b c d e] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.root).to eq 'ABCDE'
      end
    end
  end

  describe '#height' do
    context 'single block' do
      let(:blocks) { ['a'] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.height).to eq 1
      end
    end

    context 'two blocks' do
      let(:blocks) { %w[a b] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.height).to eq 2
      end
    end

    context 'more blocks' do
      let(:blocks) { %w[a b c d e f g h i j] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.height).to eq 5
      end
    end
  end

  describe '#level' do
    let(:blocks) { %w[a b c d e] }

    subject { merkle_tree.level(index) }

    context 'index = 0' do
      let(:index) { 0 }
      it { is_expected.to eq ['ABCDE'] }
    end

    context 'index = 1' do
      let(:index) { 1 }
      it { is_expected.to eq %w[ABCD E] }
    end

    context 'index = 2' do
      let(:index) { 2 }
      it { is_expected.to eq %w[AB CD E] }
    end

    context 'index = 3' do
      let(:index) { 3 }
      it { is_expected.to eq %w[A B C D E] }
    end

    describe 'invalid arguments' do
      it 'raises an ArgumentError when the index is below 0' do
        expect { merkle_tree.level(-1) }.to raise_error ArgumentError, 'index must be between 0 and 3'
      end

      it 'raises an ArgumentError when the index is greater than the height of the tree' do
        expect { merkle_tree.level(4) }.to raise_error ArgumentError, 'index must be between 0 and 3'
      end

      it 'raises an ArgumentError when the index is greater than the height of the tree' do
        expect { merkle_tree.level(5) }.to raise_error ArgumentError, 'index must be between 0 and 3'
      end
    end
  end

  context 'with SHA256 hashing' do
    subject(:merkle_tree) { described_class.new(blocks) }

    context 'single value' do
      let(:blocks) { ['bonjour'] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.root).to eq Digest::SHA2.hexdigest('bonjour')
      end
    end

    context 'single value' do
      let(:blocks) { %w[a b] }

      it 'returns the computed value of the root' do
        expect(merkle_tree.root).to eq Digest::SHA2.hexdigest(Digest::SHA2.hexdigest('a') + Digest::SHA2.hexdigest('b'))
      end
    end

    context 'bigger tree value' do
      let(:blocks) { %w[a b c d e] }

      it 'returns the computed value of the root' do
        tempab = Digest::SHA2.hexdigest(Digest::SHA2.hexdigest('a') + Digest::SHA2.hexdigest('b'))
        tempcd = Digest::SHA2.hexdigest(Digest::SHA2.hexdigest('c') + Digest::SHA2.hexdigest('d'))
        tempe = Digest::SHA2.hexdigest('e')

        tempabcd = Digest::SHA2.hexdigest(tempab + tempcd)

        expect(merkle_tree.root).to eq Digest::SHA2.hexdigest(tempabcd + tempe)
      end
    end
  end

  describe '#parent_node' do
    context 'two blocks' do
      let(:blocks) { %w[a b] }

      it 'returns the hashed value of the parent node of a given Merkle leaf' do
        expect(merkle_tree.parent_node(0)).to eq 'AB'
      end
    end

    context 'more blocks' do
      let(:blocks) { %w[a b c d e f g h i j] }

      it 'returns the value of the node that is parent to the Merkle leaf of the data block' do
        expect(merkle_tree.parent_node(4)).to eq 'EF'
      end
    end

    context 'when there is no parent' do
      let(:blocks) { ['a'] }

      it 'returns nil' do
        expect(merkle_tree.parent_node(0)).to eq nil
      end
    end

    context 'when the index is out of bounds' do
      let(:blocks) { %w[a b c] }

      it 'raises an ArgumentError if the index is out of bounds' do
        expect(merkle_tree.parent_node(3)).to eq nil
      end
    end
  end

  describe '#sibling_node' do
    context 'two blocks' do
      let(:blocks) { %w[a b] }

      it { expect(merkle_tree.sibling_node(1, 0)).to eq 'B' }
      it { expect(merkle_tree.sibling_node(1, 1)).to eq 'A' }
    end

    context 'more blocks' do
      let(:blocks) { %w[a b c d e] }
      # 0:                ABCDE
      #               /           \
      # 1:       ABCD              E
      #         /     \           /
      # 2:   AB        CD       E
      #     /  \      /  \     /
      # 3: A    B    C    D   E

      # D branch
      it { expect(merkle_tree.sibling_node(3, 3)).to eq 'C' }
      it { expect(merkle_tree.sibling_node(2, 1)).to eq 'AB' }
      it { expect(merkle_tree.sibling_node(1, 0)).to eq 'E' }

      # E branch
      it { expect(merkle_tree.sibling_node(3, 4)).to eq nil }
      it { expect(merkle_tree.sibling_node(2, 2)).to eq nil }
      it { expect(merkle_tree.sibling_node(1, 1)).to eq 'ABCD' }

      # root
      it { expect(merkle_tree.sibling_node(0, 0)).to eq nil }

      # out of bounds
      it { expect(merkle_tree.sibling_node(0, 1)).to eq nil }
      it { expect(merkle_tree.sibling_node(3, 5)).to eq nil }
    end
  end

  describe '#block_valid?' do
    let(:blocks) { %w[a b c d e] }
    subject(:merkle_tree) { described_class.new(blocks) }
    #                  ABCDE
    #              /           \
    #         ABCD              E
    #        /     \           /
    #     AB        CD       E
    #    /  \      /  \     /
    #   A    B    C    D   E
    it { expect(subject.block_valid?('a', 0)).to eq true }
    it { expect(subject.block_valid?('A', 0)).to eq false }
    it { expect(subject.block_valid?(Digest::SHA2.hexdigest('A'), 0)).to eq false }
    it { expect(subject.block_valid?('a', 1)).to eq false }
    it { expect(subject.block_valid?('b', 1)).to eq true }
    it { expect(subject.block_valid?('AB', 0)).to eq false }
    it { expect(subject.block_valid?(Digest::SHA2.hexdigest('e'), 4)).to eq false }
    it { expect(subject.block_valid?('e', 4)).to eq false }
    it { expect(subject.block_valid?('d', 3)).to eq true }
  end

  describe '#hashes_needed_to_verify' do
    context 'when the Merkle tree has 5 leaves' do
      let(:blocks) { %w[a b c d e] }

      #                  ABCDE
      #              /           \
      #         ABCD              E.
      #        /     \           /
      #     AB.        CD       E
      #    /  \      /  \      /
      #   A    B    C.    D   E
      context 'when starting with D' do
        it 'returns the list of tuples (level, index) needed to confirm that D is part of the Merkle tree' do
          expect(subject.hashes_needed_to_verify(3)).to eq %w[C AB E]
        end
      end

      context 'when starting with E' do
        it 'returns the list of tuples (level, index) needed to confirm that D is part of the Merkle tree' do
          expect(subject.hashes_needed_to_verify(4)).to eq ['ABCD']
        end
      end
    end
  end
end
