# MerkleTree

## Project structure

- [`lib/merkle_tree.rb`](/lib/merkle_tree.rb) - the implementation of the `MerkleTree` class
- [`lib/merkle_utils.rb`](/lib/merkle_utils.rb) - a series of helpful methods to use to build and leverage a `MerkleTree`
- [`questions.md`](/Questions.md) - answers to the questions from the take home exercise
- [`spec/`](/spec) - unit tests for `MerkleTree` and `MerkleUtils`
- [`bin/`](/bin) - a handful of commands to interact with the project, requires docker (see below)

---

Local setup:

```sh
# install ruby 3.0.2 using rbenv, rvm, nix, asdf...

# install bundler if you don't already have it
gem install bundler

# install the dependencies
bundle install

# run the tests
bundle exec rspec

# runs a CLI to call methods on a Merkle tree
ruby -I. lib/cli.rb

# open a REPL with the MerkleTree class loaded
irb -r ./lib/merkle_tree.rb
```

Using docker

```sh
# create the docker image
bin/setup

# run the tests
bin/test

# open a REPL with the MerkleTree class loaded
bin/console

# runs a CLI to call methods on a Merkle tree
bin/cli

# remove the docker image and containers
bin/cleanup
```

### Commands

This repo comes with a small CLI tool that can be used to call some methods against Merkle trees.

It takes two options, the method name and the hashing mechanism.

There are two hashing mechanisms available:

- `merkle`, will use `SHA256` hashing and hash the concatenated sibling hashed to calculate the parent hash
- `test`, used for easier visualization of the Merkle tree values, which "hashes" values by uppercasing them

The methods available are:

- `print`: displays each level of the Merkle tree for a set of data blocks
- `root`: returns the root of the Merkle tree for a set of data blocks
- `height`: returns the height of the Merkle tree for a set of data blocks
- `level`: returns the nodes of a level of the Merkle tree for a set of data blocks
- `verify`: given a known Merkle tree, displays whether or not a block belongs in it (using the algorithm for the additional question #1)
- `hashes_to_verify_block`: given a set of data blocks, displays which nodes of the Merkle tree would be required for a given block

Examples:

```sh
# print
$ bin/cli -m print --hashing test
enter data blocks separated with spaces
> a b c d e
0:  ABCDE
1:  ABCD    E
2:  AB    CD    E
3:  A    B    C    D    E

# root
$ bin/cli -m root --hashing test
enter data blocks separated with spaces
>  a b c d e
ABCDE

# height
$ bin/cli -m height
enter data blocks separated with spaces
> a b c d e
4

# level
$ bin/cli -m level --hashing test
enter data blocks separated with spaces
> a b c d e
enter the level of the Merkle tree to display (0 = root)
> 2
AB CD E

# verify
$ bin/cli -m verify --hashing test
enter data blocks separated with spaces
> a b c d e
enter the untrusted data
> a
enter the index of that data blocks
> 0
a is valid

$ bin/cli -m verify --hashing test
enter data blocks separated with spaces
> a b c d e
enter the untrusted data
> f
enter the index of that data blocks
> 1
f is invalid

# hashes_to_verify_block
$ bin/cli -m hashes_to_verify_block --hashing test
enter data blocks separated with spaces
> a b c d e
enter the index of a data block to verify
> 1
A
CD
E
```
