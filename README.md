# Hungry Puppies

Strategically feed the puppies to maximise their happiness.

[![Build Status](https://travis-ci.org/petertseng-dp/hungry-puppies.svg?branch=master)](https://travis-ci.org/petertseng-dp/hungry-puppies)

# Notes

As explained by the author of the challenge, this problem does have optimal substructure,
with the subproblem being "the optimal happiness of the leftmost (N-1) puppies with these N treats".
There are quite many subproblems, but it's better than checking all permutations.
We have to keep track of the last two treats given out as well, so we can calculate the happiness of the rightmost puppy.

Unfortunately, the largest input (with 30 treats) will be too memory-intensive to complete on Travis with this strategy.

# Source

https://www.reddit.com/r/dailyprogrammer/comments/33ow0c
