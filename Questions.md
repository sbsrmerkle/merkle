# Additional questions

### 1. Using the illustration above, let’s assume I know the whole Merkle tree. Someone gives me the L2 data block but I don’t trust them. How can I check if L2 data is valid?

If I know the whole Merkle tree, I should be able to verify that the L2 block is valid by getting the value of its sibling leaf Hash(0-0), building Hash(0-1) with the data from the L2 block, computing the value of the parent node in the Merkle tree, and finally comparing that to the actual value of their parent Hash(0).

Programmatically, using the Merkle tree implementation from the coding exercise, this operation would be of constant complexity. We can access in constant time both the sibling Merkle leaf and the parent node in the Merkle tree.

It would look something like this:

```rb
merkle_tree # instance of the MerkleTree
untrusted_data = '...'
untrusted_data_index = 1 # L2

parent_index = untrusted_data_index / 2 # integers division

# if the index is even, then its sibling node will be one position to the right
# if the index is odd, then its sibling node will be one position to the left
sibling_index = if untrusted_data_index % 2 == 0
  untrusted_data_index + 1
else
  untrusted_data_index - 1
end

# Retrieve the last two levels of the tree
leaves = merkle_tree.leve(merkle_tree.height - 1)
parents = merkle_tree.level(merkle_tree.height - 2)

# Retrieve the values of the parent node and the sibling node
parent_value = parents[parent_index]
sibling_value = leaves[sibling_index]

# Calculate what the parent value should be assuming that untrusted value is indeed valid
expected_value = Digest::SHA2.hexdigest(sibling_value + Digest::SHA2.hexdigest(untrusted_data))

# Compare the actual value with the expected value
assert parent_value == expected_value
```

### 2. I know only the L3 data block and the Merkle root. What is the minimum information needed to check that the L3 data block and the Merkle root belong to the same Merkle tree?

If I know L3 and I know the Merkle root, the minimum information needed to check that the block belongs in the Merkle tree is the values of Hash(1-1) and Hash(0).

- I can calculate Hash(1-0) by using the hashing function on L3.
- With Hash(1-0) and Hash(1-1) I can calculate Hash(1)
- With Hash(0) I can calculate an expected value for the Merkle root hash
- Since I know the real value of the Merkle root, if the previous value matches it, then I can conclude that L3 belongs in the Merkle tree.

To take this to a more generalized answer, any individual block can prove that it's part of the whole collection of data blocks by providing its value, plus the values of all the Merkle nodes that are sibling to the nodes on the path from its Merkle leaf to the Merkle root.

It is particularly interesting to note that this additional metadata for the block is relatively small. A Sha256 is always 64 bytes, regardless of the size of the dataset. The number of those hashes needed in the metadata grows at a log2(N) pace, where N is the number of blocks. Verification is also a log2(N) operation as it's effectively going up the path from a leaf to the root of the Merkle tree. Since all its leaves are on the same level, the height of the tree is log2(number of blocks).

![](/images/tree.jpg)

### 3. What are some Merkle tree use cases?

If I hold a Merkle root and trust its value, then I can verify that any block of data that I receive is part of the overall piece of data that I am expecting. It allows to remove the need to trust the system that sends me the data, as long as I trust that I have the right Merkle root.

Similarly, I can distribute data without needing to be trusted by the recipient.

In a P2P environment, this allows for example to break a large file into small chunks that only need to be augmented with a small amount of data to be distributed. Each peer only needs to have a full block to be able to become a distributor of that file.

The ability to break down a large file into smaller chunks greatly increases resiliency, as they are distributed faster across peers, meaning that those peers can start distributing the blocks, reducing the risk for peers dropping from the network to prevent the file from being distributed.

Peers don't need to be verified since the recipient of a block will be able to verify that each block is indeed valid only by holding the Merkle root. A 64 bytes piece of data, in our case.

The trust level comes from the hashing mechanism. It comes from the effective impossibility to create a data block that has the same hashed value as the real block.

The ability to verify that data is valid is not limited to receiving data from untrusted sources. It can be used as a general mechanism to verify data integrity. It can be helpful in a distributed environment where data moves across systems to be computed in small chunks, the Merkle root can be passed around to those systems so they can verify that the data wasn't corrupted.
