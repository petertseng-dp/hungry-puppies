module HungryPuppies
  alias Treat = UInt32
  alias Happiness = Int32

  def self.max_happiness_possibilities(treats : Array(Treat)) : Tuple(Happiness, Array(Array(Treat)))
    treats.sort

    # Possible optimal happinesses for the left (N-1) puppies,
    # using the given list of N treats.
    best = Hash(Array(Treat), Array(Tuple(Array(Treat), Happiness))).new { |h, k|
      h[k] = [] of Tuple(Array(Treat), Happiness)
    }

    # This assumes that each_combination maintains the original element order.
    # Particularly, we care that the sort order is maintained,
    # because the keys in `seen` and `@best` are sorted.
    # If this becomes not true, we can sort each combination,
    # but it will take more time.

    # Initialize best with every two-combination
    # (in block so that seen's scope is limited)
    Set(Array(Treat)).new.tap { |seen|
      treats.each_combination(2) { |combo|
        next if seen.includes?(combo)
        seen.add(combo)
        a, b = combo
        if a == b
          best[combo] = [{[a, b], 0}]
        else
          # Because {a, b} => -1 is too low.
          best[combo] = [{[b, a], 1}]
        end
      }
    }

    (3..treats.size).each { |n|
      seen = Set(Array(Treat)).new
      treats.each_combination(n) { |combo|
        next if seen.includes?(combo)
        seen.add(combo)

        seen_sub = Set(Treat).new
        candidates = combo.each_with_index.flat_map { |rightmost, i|
          next [] of Tuple(Array(Treat), Happiness) if seen_sub.includes?(rightmost)
          seen_sub.add(rightmost)

          rest = combo[0...i] + combo[(i + 1)..-1]

          best[rest].map { |prev_best, prev_happiness|
            a = prev_best[-2]
            b = prev_best[-1]
            new_happiness = prev_happiness
            new_happiness += 1 if b > a && b > rightmost
            new_happiness -= 1 if b < a && b < rightmost
            {prev_best + [rightmost], new_happiness}
          }
        }

        max_happiness = candidates.map { |_, h| h }.max
        best[combo] = candidates.select { |_, h| h + 1 >= max_happiness }
      }

      # We can delete the unneeded entries now to save space.
      best.delete_if { |k, _| k.size < n }
    }

    candidates = best[treats].map { |treats, happiness|
      a = treats[-2]
      b = treats[-1]
      new_happiness = happiness
      new_happiness += 1 if b > a
      new_happiness -= 1 if b < a
      {treats, new_happiness}
    }

    max_happiness = candidates.map { |_, h| h }.max
    {max_happiness, candidates.select { |_, h| h == max_happiness }.map { |t, _| t }}
  end

  # An attempt to use less memory by only storing the last two treats.
  # Unfortunately, duplicates code.
  def self.max_happiness(treats : Array(Treat)) : Tuple(Happiness, UInt32)
    treats.sort

    # Possible optimal happinesses for the left (N-1) puppies,
    # using the given list of N treats, and rightmost two treats
    best = Hash(Array(Treat), Array(Tuple(Treat, Treat, Happiness))).new { |h, k|
      h[k] = [] of Tuple(Treat, Treat, Happiness)
    }

    # This assumes that each_combination maintains the original element order.
    # Particularly, we care that the sort order is maintained,
    # because the keys in `seen` and `@best` are sorted.
    # If this becomes not true, we can sort each combination,
    # but it will take more time.

    # Initialize best with every two-combination
    # (in block so that seen's scope is limited)
    Set(Array(Treat)).new.tap { |seen|
      treats.each_combination(2) { |combo|
        next if seen.includes?(combo)
        seen.add(combo)
        a, b = combo
        if a == b
          best[combo] = [{a, b, 0}]
        else
          # Because {a, b} => -1 is too low.
          best[combo] = [{b, a, 1}]
        end
      }
    }

    (3..treats.size).each { |n|
      seen = Set(Array(Treat)).new
      treats.each_combination(n) { |combo|
        next if seen.includes?(combo)
        seen.add(combo)

        seen_sub = Set(Treat).new
        candidates = combo.each_with_index.flat_map { |rightmost, i|
          next [] of Tuple(Treat, Treat, Happiness) if seen_sub.includes?(rightmost)
          seen_sub.add(rightmost)

          rest = combo[0...i] + combo[(i + 1)..-1]

          best[rest].map { |a, b, prev_happiness|
            new_happiness = prev_happiness
            new_happiness += 1 if b > a && b > rightmost
            new_happiness -= 1 if b < a && b < rightmost
            {b, rightmost, new_happiness}
          }
        }

        max_happiness = candidates.map { |_, _, h| h }.max
        best[combo] = candidates.select { |_, _, h| h + 1 >= max_happiness }
      }

      # We can delete the unneeded entries now to save space.
      best.delete_if { |k, _| k.size < n }
    }

    candidates = best[treats].map { |a, b, happiness|
      new_happiness = happiness
      new_happiness += 1 if b > a
      new_happiness -= 1 if b < a
      new_happiness
    }

    max = candidates.max
    {max, candidates.count { |h| h == max }.to_u32}
  end
end
