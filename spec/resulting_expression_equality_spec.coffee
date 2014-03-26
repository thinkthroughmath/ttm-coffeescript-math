#= require lib/math/expression_components
#= require lib/math/resulting_expression_equality

ttm = thinkthroughmath

describe "expression equality", ->
  beforeEach ->
    @isEqual = ttm.lib.math.ResultingExpressionEquality.isEqual

  describe "numbers", ->
    it "with different values are different", ->
      expect(@isEqual(10, 11)).toEqual false

    it "is equal with two of the same value", ->
      expect(@isEqual(10, 10)).toEqual true

    it "is not rounded", ->
      expect(@isEqual(10.111, 10.11)).toEqual false

    it "ignores trailing 0s", ->
      expect(@isEqual(8, 8.00)).toEqual true