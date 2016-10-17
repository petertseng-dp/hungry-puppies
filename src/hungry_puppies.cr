module HungryPuppies
  enum Ordering
    GT
    EQ
    LT
  end

  alias Treat = UInt32
  alias Happiness = Int32
  alias Relation = Tuple(Ordering, Treat)

  def self.met?(r : Relation, t : Treat) : Bool
    ord, tt = r
    case ord
    when Ordering::GT; t > tt
    when Ordering::EQ; t == tt
    when Ordering::LT; t < tt
    else raise "Unknown relation #{r}"
    end
  end

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

  # Uses less memory because it only returns one possibility.
  def self.max_happiness(treats : Array(Treat)) : Tuple(Happiness, Array(Treat))
    treats.sort
    seen = {} of Tuple(Array(Treat), Relation?) => Tuple(Happiness, Array(Treat))?
    max_happiness(treats, nil, seen).not_nil!
  end

  private def self.max_happiness(treats : Array(Treat), relation : Relation?, seen : Hash(Tuple(Array(Treat), Relation?), Tuple(Happiness, Array(Treat))?)) : Tuple(Happiness, Array(Treat))?
    if treats.size == 1
      return {0, treats} if relation.nil?
      return nil unless met?(relation, treats[0])
      ord, _ = relation
      case ord
      when Ordering::GT; return {1, treats}
      when Ordering::EQ; return {0, treats}
      when Ordering::LT; return {-1, treats}
      else raise "Unknown relation #{relation}"
      end
    end

    return seen[{treats, relation}] if seen.has_key?({treats, relation})

    tried = Set(Treat).new

    best = nil

    treats.each_with_index { |treat, i|
      next if tried.includes?(treat)
      tried.add(treat)

      next unless relation.nil? || met?(relation, treat)

      rest = treats[0...i] + treats[(i + 1)..-1]

      try_replace = ->(h : Happiness, ts : Array(Treat)) {
        tmp_best = best
        best = {h, [treat] + ts} if tmp_best.nil? || h > tmp_best[0]
      }

      gt = max_happiness(rest, {Ordering::GT, treat}, seen)
      eq = max_happiness(rest, {Ordering::EQ, treat}, seen)
      lt = max_happiness(rest, {Ordering::LT, treat}, seen)

      if gt
        h, o = gt
        h -= 1 if relation.nil? || relation[0] == Ordering::LT
        try_replace.call(h, o)
      end
      if lt
        h, o = lt
        h += 1 if relation.nil? || relation[0] == Ordering::GT
        try_replace.call(h, o)
      end
      try_replace.call(*eq) if eq
    }

    seen[{treats, relation}] = best
  end
end
