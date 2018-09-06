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
