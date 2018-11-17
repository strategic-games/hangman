# Utility
Often it is necessary to implement some general-purpose data structures and algorithms, because they are a bit to special to be provided by the language.

## SortedSet
SortedSet is a Set whose elements do not need to conform to Hashable, but to Comparable protocol. It keeps its elements in order and searches via binary search.

## Radix
Radix is a radix search tree for strings I implemented to make searching by prefix or pattern faster.

## Matrix
Matrix is a 2D grid which can hold any kind of elements. It provides various subscripts and access methods to query single elements, rows, columns etc.

## Math
Numeric types, collections, and Matrix are extended with some extra math operators and methods like sum, elementwise multiplication, and 2D convolution.

## Random number generators
I needed a seedable rng for repeatable simulation results. So I included the swift implementations of some prng introduced in [this article](https://www.cocoawithlove.com/blog/2016/05/19/random-numbers.html). Besides, I added the [SplitMix64](http://xoshiro.di.unimi.it/splitmix64.c) which is recommended by [Vigna & Blackman](http://xoshiro.di.unimi.it) to seed their Xoshiro256** prng with a 64-bit number.
