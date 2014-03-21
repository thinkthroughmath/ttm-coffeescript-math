#= require lib/math/expression_components
#= require lib/math/resulting_expression_equality

ttm = thinkthroughmath

describe "expression equality", ->
  beforeEach ->
    @comps = ttm.lib.math.ExpressionComponentSource.build()
    @isEqual = ttm.lib.math.ResultingExpressionEquality.isEqual
    builder_lib = ttm.lib.math.BuildExpressionFromJavascriptObject

    @math = ttm.lib.math.math_lib.build()
    @exp_builder = @math.object_to_expression.buildExpressionFunction()

  describe "numbers", ->
    it "with different values are different", ->
      expect(
        @isEqual(
          @comps.build_number(value: 10),
          @comps.build_number(value: 11)
        )).toEqual false

    it "is equal with two of the same value", ->
      expect(
        @isEqual(
          @comps.build_number(value: 10),
          @comps.build_number(value: 10)
        )).toEqual true

    it "is not rounded", ->
      expect(
        @isEqual(
          @comps.build_number(value: 10.111),
          @comps.build_number(value: 10.11)
        )).toEqual false
