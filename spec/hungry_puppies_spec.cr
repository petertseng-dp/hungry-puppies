require "spec"
require "../src/hungry_puppies"

def happiness(treats)
  treats.map_with_index { |me, i|
    neighbors = [i == 0 ? nil : treats[i - 1], treats[i + 1]?].compact
    if neighbors.all? { |n| me > n }
      1
    elsif neighbors.all? { |n| me < n }
      -1
    else
      0
    end
  }.sum
end

describe HungryPuppies do
  cases = [
    {2, [1, 2, 2, 3, 3, 3, 4]},
    {4, [1, 1, 2, 3, 3, 3, 3, 4, 5, 5]},
    {4, [1, 1, 2, 2, 3, 4, 4, 5, 5, 5, 6, 6]},
  ]

  it "works" do
    cases.each { |expected, treats|
      max, possibilities = HungryPuppies.max_happiness_possibilities(treats.map(&.to_u32))
      max.should eq(expected)
      possibilities.each { |p| happiness(p).should eq(max) }
    }
  end

  if false
    it "works on big" do
      expected, treats = {10, [1, 1, 2, 2, 2, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9]}
      max, possibilities = HungryPuppies.max_happiness(treats.map(&.to_u32))
      max.should eq(expected)
      puts "#{possibilities} possibilities"
    end
  end
end
