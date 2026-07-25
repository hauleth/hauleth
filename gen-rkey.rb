require 'date'

ENCODE_CHARS = "234567abcdefghijklmnopqrstuvwxyz".chars.freeze

def encode(num)
  str = ""

  while num > 0
    str << ENCODE_CHARS[num % 32]

    num /= 32
  end

  str.reverse.rjust(13, ENCODE_CHARS[0])
end

dt = Date.parse(ARGV[1]).to_time

srand(dt.to_i)

ts = dt.to_i << (20 + 10)
r = rand(1 << (20 + 10) - 1)

key = ts + r

puts encode(key)
