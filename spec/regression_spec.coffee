ttm = thinkthroughmath
expect_evaluation = (orig, goal)->
  exp = @exp(orig)
  new_exp = @evaluation.build(exp).resultingExpression()
  expect(new_exp).toBeAnEqualExpressionTo @exp(goal)

describe "Bugs: ", ->
  describe "expression evaluation", ->
    beforeEach ->
      @evaluation = ttm.lib.math.ExpressionEvaluation
      @math = ttm.lib.math.math_lib.build()
      builder_lib = ttm.lib.math.BuildExpressionFromJavascriptObject
      @exp = @math.object_to_expression.buildExpressionFunction()
      @expect_evaluation = expect_evaluation

    it "evaluates this expression correctly", ->
      @expect_evaluation(
        [
          [
            "41", '/', "32.75", '-', '1'
          ], '*', '100'
        ],
        '25.19'
      )

    it "evaluates this expression with a fractional component correctly", ->
      @expect_evaluation([{'^': [6, 3]}, '*', '3.14', '*', {fraction: [4, 3]}],
        '904.32'
      )

