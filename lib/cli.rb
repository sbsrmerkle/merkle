# This code is included in the repo because it makes it handy to
# verify that the project works without having to write ruby scripts
# However, it's not the highest quality and is just a quick and dirty way
# to call methods on the MerkleTree and MerkleUtils classes
#
# Please don't judge the code in this file too harshly 🙏

require 'optparse'
require 'readline'
require 'lib/merkle_tree'

options = {
  hashing: 'merkle'
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('--hashing [HASHING]', '', 'Specify the hashing method (merkle or test)') do |hashing_name|
    options[:hashing] = String(hashing_name).downcase
  end

  opts.on('--method [METHOD]', '-m [METHOD]',
          'Specify the method (hashes_to_verify_block, height, level, print, root, verify)') do |method_name|
    options[:method] = String(method_name).downcase
  end
end

parser.parse!

def root(hashing)
  puts MerkleTree.new(read_blocks, hashing).root
end

def height
  puts MerkleTree.new(read_blocks).height
end

def level(hashing)
  data_blocks = read_blocks

  level = read_int('level', 'enter the level of the Merkle tree to display (0 = root)')

  puts MerkleTree.new(data_blocks, hashing).level(level.to_i).join(' ')
end

def verify(hashing)
  if hashing == TestHashing
    warn 'Warning: TestHashing is handy for visualization but makes for a poor hashing mechanism. You might get false positives.'
  end

  data_blocks = read_blocks

  block_data = read_str('data', 'enter the untrusted data')
  block_index = read_int('index', 'enter the index of that data blocks')

  tree = MerkleTree.new(data_blocks, hashing)

  if tree.block_valid?(block_data, block_index)
    puts "#{block_data} is valid"
  else
    puts "#{block_data} is invalid"
  end
end

def hashes_to_verify_block(hashing)
  data_blocks = read_blocks

  block_index = read_int('index', 'enter the index of a data block to verify')

  puts MerkleTree.new(data_blocks, hashing).hashes_needed_to_verify(block_index)
end

def read_str(key, message)
  puts message
  input = Readline.readline('> ', true)
  raise ArgumentError, "#{key} is required" if input.strip.empty?

  input
end

def read_int(key, message)
  puts message
  input = Readline.readline('> ', true)
  raise ArgumentError, "#{key} must be an integer" if input.to_i.to_s != input.strip

  input.to_i
end

def print(hashing)
  data_blocks = read_blocks
  MerkleUtils.print(MerkleTree.new(data_blocks, hashing))
end

def read_blocks
  puts 'enter data blocks separated with spaces'
  data_blocks = Readline.readline('> ', true)
  exit(0) if data_blocks.nil?
  data_blocks = data_blocks.strip.split(/\s+/)
  exit(0) if data_blocks.empty?
  data_blocks
end

hashing = {
  'test' => TestHashing,
  'merkle' => MerkleHashing
}.fetch(options[:hashing], MerkleHashing)

begin
  case options[:method]
  when 'root'
    root(hashing)
  when 'height'
    height
  when 'level'
    level(hashing)
  when 'print'
    print(hashing)
  when 'verify'
    verify(hashing)
  when 'hashes_to_verify_block'
    hashes_to_verify_block(hashing)
  else
    warn parser.to_s
    exit(1)
  end
rescue ArgumentError => e
  warn "ERR: #{e.message}"
  exit 1
end
