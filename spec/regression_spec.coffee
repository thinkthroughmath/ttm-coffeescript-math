ttm = thinkthroughmath
expect_evaluation = (orig, goal)->
  exp = @exp(orig)
  new_exp = @evaluation.build(exp).resultingExpression()
  expect(new_exp).toBeAnEqualExpressionTo @exp(goal)

describe "regression tests / bugs: ", ->
  describe "expression evaluation", ->
    beforeEach ->
      @evaluation = ttm.lib.math.ExpressionEvaluation
      @math = ttm.lib.math.math_lib.build()
      @exp = @math.object_to_expression.buildExpressionFunction()
      @expp = @math.object_to_expression.buildExpressionPositionFunction()
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


    it "returns an isError() expression when expression contains an incomplete subexpression", ->

      expr = @expp()
      expr = @math.commands.build_append_number({value: 78}).perform(expr)
      expr = @math.commands.build_append_multiplication().perform(expr)
      expr = @math.commands.build_append_sub_expression().perform(expr)
      expr = @math.commands.build_square_root().perform(expr)
      expect(expr.expression().isError()).toBeTruthy()

    it "handles this case that was a bug in the equationbuilder", ->
      expr = @expp()
      expr = @math.commands.build_append_sub_expression().perform(expr)
      # throws exception
      expr = @math.commands.build_append_addition().perform(expr)
