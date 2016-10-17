require "./src/hungry_puppies"

if ARGV.delete("-v")
  happiness, possibilities = HungryPuppies.max_happiness_possibilities(ARGV.map(&.to_u32))
  possibilities.each { |p| puts p }
  puts "#{happiness} (#{possibilities.size} possibilities)"
else
  puts HungryPuppies.max_happiness(ARGV.map(&.to_u32))
end
