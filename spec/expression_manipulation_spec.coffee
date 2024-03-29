ttm = thinkthroughmath
class_mixer = ttm.class_mixer

it_plays_manipulation_role = (options)->
  describe "acting as an expression manipulation", ->
    beforeEach ->
      @subject = options.subject.call(@)

    it "has a perform method", ->
      expect(typeof @subject.perform).toEqual "function"

    it "returns an ExpressionPosition object", ->
      orig = options.expression_for_performance.call(@)
      results = @subject.perform(orig)
      unless results instanceof ttm.lib.math.ExpressionPosition
        throw "The return value was not an instance of expression position"

it_inserts_components_where_pointed_to = (specifics)->
  describe "#{specifics.name} inserts correctly when position is", ->
    it "works with a base case", ->
      start =
        if specifics.basic_start_expression
          specifics.basic_start_expression.call(@)
        else
          @exp_pos_builder()
      subject = specifics.subject.call(@)
      new_exp = subject.perform(start)
      expect(new_exp.expression()).toBeAnEqualExpressionTo(
       specifics.basic_should_equal_after.call(@)
      )

describe "expression manipulations", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @pos = @math.expression_position
    @manip = @math.commands
    @components = @math.components

    builder_lib = ttm.lib.math.BuildExpressionFromJavascriptObject
    @exp_builder = @math.object_to_expression.buildExpressionFunction()
    @exp_pos_builder = @math.object_to_expression.buildExpressionPositionFunction()
    expression_to_string = ttm.lib.math.ExpressionToString.toString
    @expect_value = (expression, value)->
      expect(expression_to_string(expression)).toEqual value

  describe "a proof-of-concept example", ->
    it "produces the correct result TODO make this larger", ->
      exp = @exp_builder()
      exp_pos = ttm.lib.math.ExpressionPosition.build(position: exp.id(), expression: exp)
      exp_pos = @manip.build_append_number(value: 1).perform(exp_pos)
      exp_pos = @manip.build_append_number(value: 0).perform(exp_pos)
      exp_pos = @manip.build_append_multiplication().perform(exp_pos)
      exp_pos = @manip.build_append_sub_expression().perform(exp_pos)
      exp_pos = @manip.build_append_number(value: 2).perform(exp_pos)
      exp_pos = @manip.build_append_addition().perform(exp_pos)
      exp_pos = @manip.build_append_number(value: 4).perform(exp_pos)
      exp_pos = @manip.build_exit_sub_expression().perform(exp_pos)

      expected = @exp_builder(10, '*', [2, '+', 4])
      expect(exp_pos.expression()).toBeAnEqualExpressionTo expected

  describe "appending multiplication", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_multiplication()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'multiplication'
      subject: -> @manip.build_append_multiplication()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '*'
    )

    it "does nothing if the expression is empty", ->
      exp_pos = @exp_pos_builder()
      exp_pos = @manip.build_append_multiplication().perform(exp_pos)
      expected = @exp_builder()
      expect(exp_pos.expression()).toBeAnEqualExpressionTo expected

    it "adds multiplication to the end of the expression", ->
      exp_pos = @exp_pos_builder(1)
      results = @manip.build_append_multiplication().perform(exp_pos)
      expect(results.expression().last() instanceof @components.classes.multiplication).toEqual true

    it "correctly adds multiplication after an exponentiation", ->
      exp_pos = @exp_pos_builder('^': [1, 2])
      new_exp = @manip.build_append_multiplication().perform(exp_pos)
      expected = @exp_builder({'^': [1, 2]}, '*')
      expect(new_exp.expression()).toBeAnEqualExpressionTo expected

  describe "exponentiate last element", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_exponentiate_last()
      expression_for_performance: ->
        @exp_pos_builder()

    it_inserts_components_where_pointed_to(
      name: 'exponentiation'
      subject: -> @manip.build_exponentiate_last()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder '^': [1,[]]
    )

    describe "on a single number-only expression", ->
      beforeEach ->
        exp = @exp_pos_builder(10)
        @new_exp = @manip.build_exponentiate_last().perform(exp).expression()

      it "replaces the content of the expression with an exponentiation", ->
        expect(@new_exp.first()).toBeInstanceOf @components.classes.exponentiation

      it "provides the exponentiation its base", ->
        expect(@new_exp.first().base()).toBeAnEqualExpressionTo @exp_builder([10]).first()

    describe "on an expression that currently ends with an operator ", ->
      it "replaces the trailing operator", ->
        exp = @exp_pos_builder(10, '+')
        new_exp = @manip.build_exponentiate_last().perform(exp).expression()
        expected = @exp_builder('^': [10, null])
        expect(new_exp).toBeAnEqualExpressionTo expected

    describe "on an expression that has a trailing exponent", ->
      it "manipulates expression correctly", ->
        exp = @exp_pos_builder('^': [10, []])
        new_exp = @manip.build_exponentiate_last().perform(exp).expression()
        expected = @exp_builder('^': [10, []])
        expect(new_exp).toBeAnEqualExpressionTo expected

  describe "appending a number", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_number(value: 8)
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "inserts a number when the expression is empty", ->
      @exp_pos = @exp_pos_builder()
      exp = @manip.build_append_number(value: 8).perform(@exp_pos)
      expected = @exp_builder(8)
      expect(exp.expression()).toBeAnEqualExpressionTo expected

    describe "when the previous element is a closed expression", ->
      beforeEach ->
        @exp_pos = @exp_pos_builder([1])

      it "adds a multiplication symbol between elements", ->
        exp = @manip.build_append_number(value: 11).perform(@exp_pos)
        expected = @exp_builder([1], '*', 11)
        expect(exp.expression()).toBeAnEqualExpressionTo expected

  describe "appending exponentiation", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_exponentiation()
      expression_for_performance: ->
        @exp_pos_builder(10)

    describe "when the currently displayed element is ", ->
      beforeEach ->
        @exp_pos = @exp_pos_builder([[]])

      it "adds the number at the correct place", ->
        @exp_pos = @manip.utils.build_expression_position_manipulator().
          updatePositionTo(@exp_pos, (comp)->
            comp.isExpression() &&
              comp.parent() &&
              comp.parent().isExpression() &&
              comp.parent().parent()
          )

        exp = @manip.build_append_number(value: 8).
          perform(@exp_pos)

        expected = @exp_builder([[8]])

        expect(exp.expression()).toBeAnEqualExpressionTo expected

    describe "when the pointed-at element is an exponentiation ", ->
      describe "with no power", ->
        beforeEach ->
          @exp = @exp_pos_builder('^': [10, cursor([])])

        it "inserts the number into the exponentiation", ->
          new_exp = @manip.build_append_number(value: 11).perform(@exp)
          expected = @exp_builder('^': [10, 11])

          expect(new_exp.expression()).toBeAnEqualExpressionTo expected

      describe "with a power", ->
        beforeEach ->
          @exp_pos = @exp_pos_builder('^': [10, 11])

        it "inserts a multiplication and then the number", ->
          new_exp = @manip.build_append_number(value: 7).perform(@exp_pos)
          expected = @exp_builder({'^': [10,11]}, '*', 7)
          expect(new_exp.expression()).toBeAnEqualExpressionTo expected

    describe "when the pointed at element is not one of those special cases", ->
      it "adds the number as a new number", ->
        exp_pos = @exp_pos_builder(1, '+', 3, '=')
        manipulated_exp = @manip.build_append_number(value: 8).perform(exp_pos)
        expected = @exp_builder(1, '+', 3, '=', 8)
        expect(manipulated_exp.expression()).toBeAnEqualExpressionTo expected

  describe "appending an equals", ->
    it "inserts an equals sign into the equation", ->
      @exp = @exp_pos_builder(1, '+', 3)
      new_exp = @manip.build_append_equals().perform(@exp).expression()
      expected = @exp_builder(1, '+', 3, '=')
      expect(new_exp).toBeAnEqualExpressionTo expected

  describe "appending a sub expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_sub_expression()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'appending a sub expression'
      subject: -> @manip.build_append_sub_expression()
      basic_start_expression: -> @exp_pos_builder()
      basic_should_equal_after: -> @exp_builder []
    )

    it "adds a sub-expression to the expression", ->
      @exp = @exp_pos_builder(1, '+')
      new_exp = @manip.build_append_sub_expression().perform(@exp).expression()
      expected = @exp_builder(1, '+', [])
      expect(new_exp).toBeAnEqualExpressionTo expected

    describe "when adding to a sub-expression", ->
      it "should add everything correctly", ->
        exp = @exp_pos_builder()
        exp = @manip.build_append_number(value: 6).perform(exp)
        exp = @manip.build_append_addition().perform(exp)

        exp = @manip.build_append_sub_expression().perform(exp)
        exp = @manip.build_append_number(value: 6).perform(exp)
        exp = @manip.build_append_addition().perform(exp)

        exp = @manip.build_append_sub_expression().perform(exp)
        exp = @manip.build_exit_sub_expression().perform(exp)
        exp = @manip.build_exit_sub_expression().perform(exp)
        expected = @exp_builder(6, '+', [6, '+', []])

        expect(exp.expression()).toBeAnEqualExpressionTo expected

  describe "exiting a sub expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_exit_sub_expression()

      expression_for_performance: ->
        ret = @exp_pos_builder([cursor([])])

        # we need to set the pointed position to the id of the open expression
        ret.clone(position: ret.expression().first().id())

    it "moves the position outside of the sub-expression", ->
      exp = @exp_pos_builder([cursor([])])
      new_exp = @manip.build_exit_sub_expression().perform(exp)
      actual = new_exp.expression()
      expected = @exp_builder([[]])
      expect(actual).toBeAnEqualExpressionTo expected
      expect(new_exp.position()).not.toEqual(exp.position())
      expect(new_exp.position()).toEqual(exp.expression().last().id())

    it "correctly handles closing a nested open subexpression that is pointed at", ->
      exp = @exp_pos_builder([cursor([])])
      exp = exp.clone position: exp.expression().first().first().id()
      new_exp = @manip.build_exit_sub_expression().perform(exp)
      expected = @exp_builder([[]])
      expect(new_exp.expression()).toBeAnEqualExpressionTo expected


  describe "appending division", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_division()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a division to the expression", ->
      exp = @exp_pos_builder(1)

      new_exp = @manip.build_append_division().perform(exp)
      expect(new_exp.expression().last() instanceof @components.classes.division).toBeTruthy()

    it_inserts_components_where_pointed_to(
      name: 'division'
      subject: -> @manip.build_append_division()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '/'
    )

  describe "appending addition", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_addition()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'addition'
      subject: -> @manip.build_append_addition()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '+'
    )

    it "adds addition to the end of the expression", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_addition().perform(exp)
      expect(new_exp.expression().last() instanceof @components.classes.addition).toEqual true


  describe "appending subtraction", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_subtraction()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'subtraction'
      subject: -> @manip.build_append_subtraction()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '-'
    )

    it "adds subtraction to the end of the expression", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_subtraction().perform(exp)
      expect(new_exp.expression().last() instanceof @components.classes.subtraction).toEqual true

  describe "appending a decimal", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_decimal(value: 5)
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'append decimal'
      subject: -> @manip.build_append_decimal()
      basic_start_expression: -> @exp_pos_builder '1'
      basic_should_equal_after: -> @exp_builder '1.'
    )

    it "adds an implicit multiplication after a variable", ->
      exp = @exp_pos_builder({variable: "doot"})
      new_exp = @manip.build_append_decimal().perform(exp).expression()
      expect(new_exp.last().isNumber()).toBeTruthy()
      expect(new_exp.last(1).isMultiplication()).toBeTruthy()

    it "correctly adds a decimal to the value", ->
      exp = @exp_pos_builder()
      exp = @manip.build_append_number(value: 1).perform(exp)
      exp = @manip.build_append_decimal().perform(exp)
      exp = @manip.build_append_number(value: 1).perform(exp)
      @expect_value(exp, '1.1')

    it "adds only one decimal to the value", ->
      exp = @exp_pos_builder()
      exp = @manip.build_append_number(value: 1).perform(exp)
      exp = @manip.build_append_decimal().perform(exp)
      exp = @manip.build_append_number(value: 1).perform(exp)
      exp = @manip.build_append_decimal().perform(exp)
      exp = @manip.build_append_number(value: 1).perform(exp)
      @expect_value(exp, '1.11')

  describe 'calculate expression', ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_calculate()
      expression_for_performance: ->
        @exp_pos_builder(5)

    describe '.perform()', ->
      beforeEach ->
        @exp = @exp_pos_builder(6)
        @exp = @manip.build_append_division().perform(@exp)
        @exp = @manip.build_append_number(value: 2).perform(@exp)
        @new_exp = @manip.build_calculate().perform(@exp)

      it 'collapses Expression array', ->
        collapsed_exp = @exp_pos_builder(3)

        expect(@new_exp.expression()).toBeAnEqualExpressionTo collapsed_exp.expression()

      it 'retains the position value', ->
        expect(@new_exp.position()).toEqual @exp.position()

      it 'retains id of cloned Expression object', ->
        expect(@new_exp.expression().id()).toEqual @exp.expression().id()

      describe 'with error state', ->
        beforeEach ->
          @exp = @manip.build_append_division().perform(@new_exp)
          @new_exp = @manip.build_calculate().perform(@exp)

        it 'sets error state and clears array in Expression object', ->
          error_exp = @exp_pos_builder()
          error_exp.expr.is_error = true

          expect(@new_exp.expr).toBeAnEqualExpressionTo error_exp.expression()

  describe "square expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_square()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "returns a squared expression", ->
      exp = @exp_pos_builder(10)
      squared = @manip.build_square().perform(exp)
      @expect_value(squared, '100')

  describe "appending root", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_root()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a mulitplication and root to the expression", ->
      exp = @exp_pos_builder([1])

      new_exp = @manip.build_append_root(degree: 2).perform(exp).expression()

      expect(new_exp.last()).toBeInstanceOf @components.classes.root
      expect(new_exp.last(1)).toBeInstanceOf @components.classes.multiplication

    it "adds root and an addition to the expression", ->
      exp = @exp_pos_builder()
      exp = @manip.build_append_number(value: 8).perform(exp)
      exp = @manip.build_append_number(value: 1).perform(exp)
      exp = @manip.build_square_root().perform(exp)
      exp = @manip.build_append_addition().perform(exp)
      exp = @manip.build_append_sub_expression().perform(exp)
      exp = @manip.build_append_number(value: 2).perform(exp)
      exp = @manip.build_append_addition().perform(exp)
      exp = @manip.build_append_number(value: 4).perform(exp)
      exp = @manip.build_exit_sub_expression().perform(exp)

      expected = @exp_builder(9, '+', [2, '+', 4])
      expect(exp.expression()).toBeAnEqualExpressionTo expected

  describe "appending variable", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_variable()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds itself to an empty expression", ->
      exp = @exp_pos_builder()
      new_exp = @manip.build_append_variable(variable: "doot").perform(exp)
      expected = @exp_builder(variable: "doot")
      expect(new_exp.expression()).toBeAnEqualExpressionTo expected


  describe "reset expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_reset()

      expression_for_performance: ->
        false # not important at all

    beforeEach ->
      @reset = @manip.build_reset()
      @result = @reset.perform()

    it "returns an empty resulting expression", ->
      expect(@result.expression()).toBeAnEqualExpressionTo @exp_builder()

    it "returns an pointer which points to that expression", ->
      expect(@result.position()).toEqual @result.expression().id()

  describe "update position", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_update_position()

      expression_for_performance: ->
        @exp_pos_builder()

  describe "negate last", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_negate_last()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "will negate the last element", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_negate_last().perform(exp)
      expect(new_exp.expression().last().value()).toEqual -1

    it "does nothing when the last element is not a number", ->
      exp = @exp_pos_builder()
      new_exp = @manip.build_negate_last().perform(exp)
      expect(new_exp.expression().last()).toEqual undefined

  describe "appending pi", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_pi()

      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a mulitplication and pi to the expression", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_pi().perform(exp).expression()
      expect(new_exp.last()).toBeInstanceOf @components.classes.pi
      expect(new_exp.last(1)).toBeInstanceOf @components.classes.multiplication

    it "allows the value of pi to be specified", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_pi(value: "1").perform(exp).expression()
      expect(new_exp.last()).toBeInstanceOf @components.classes.pi
      expect(new_exp.last().value()).toEqual "1"

  describe "appending a fraction", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_fraction()
      expression_for_performance: ->
        @exp_pos_builder()

    it "adds a numerator/denominator where we expect", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_fraction().perform(exp).expression()

      expect(new_exp.last()).toBeInstanceOf @components.classes.fraction
      expect(new_exp.last().numerator()).toBeInstanceOf @components.classes.expression
      expect(new_exp.last().denominator()).toBeInstanceOf @components.classes.expression

  describe "appending a function", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_fn()
      expression_for_performance: ->
        @exp_pos_builder()
    it_inserts_components_where_pointed_to(
      name: 'fn'
      subject: -> @manip.build_append_fn(name: 'doot')
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '*', {fn: ["doot", []]}
    )

    it "adds a function element", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_fn().perform(exp).expression()

      expect(new_exp.last()).toBeInstanceOf @components.classes.fn
      expect(new_exp.last().argument()).toBeInstanceOf @components.classes.expression

    it "inserts a multiplication symbol between variables and functions", ->
      exp = @exp_pos_builder(variable: "face")
      new_exp = @manip.build_append_fn(name: "doot", argument: @components.build_expression()).perform(exp).expression()
      expect(new_exp).toBeAnEqualExpressionTo(
        @exp_builder({variable: "face"}, '*', {fn: ["doot", []]})
      )

  describe "take the square root", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_square_root()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "finds the square root of an expression", ->
      exp = @exp_pos_builder([4])
      new_exp = @manip.build_square_root().perform(exp)
      expect(new_exp.expression().last().value()).toEqual '2'

  describe "substituting variables", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_substitute_variables(variables: [{name: "funky", value: "10"}])
      expression_for_performance: ->
        @exp_pos_builder({variable: "funky"})

    it "substitutes variables", ->
      exp_pos = @exp_pos_builder({variable: "funky"})
      manip = @manip.build_substitute_variables(variables: [{name: "funky", value: "10"}])
      new_exp = manip.perform(exp_pos)
      expect(new_exp.expression()).toBeAnEqualExpressionTo(@exp_pos_builder(10).expression())

  describe "getting different sides of an equation", ->
    describe "getting left side", ->
      it_plays_manipulation_role
        subject: ->
          @manip.build_get_left_side()
        expression_for_performance: ->
          @exp_pos_builder({variable: "funky"}, '=', {variable: 'chunky'})

      it "returns left sides of equation", ->
        expr = @exp_pos_builder({variable: "funky"}, '=', {variable: 'chunky'})
        new_exp = @manip.build_get_left_side().perform(expr)
        expected = @exp_builder({variable: 'funky'})
        expect(new_exp.expression()).toBeAnEqualExpressionTo(expected)

    describe "getting right side", ->
      it_plays_manipulation_role
        subject: ->
          @manip.build_get_right_side()
        expression_for_performance: ->
          @exp_pos_builder({variable: "funky"}, '=', {variable: 'chunky'})

      it "returns right side of equation", ->
        expr = @exp_pos_builder({variable: "funky"}, '=', {variable: 'chunky'})
        new_exp = @manip.build_get_right_side().perform(expr)
        expected = @exp_builder({variable: 'chunky'})
        expect(new_exp.expression()).toBeAnEqualExpressionTo(expected)

  describe "removing the pointed-at element", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_remove_pointed_at()
      expression_for_performance: ->
        @exp_pos_builder({variable: "funky"}, '=', {variable: 'chunky'})

    it "removes an item from  an expression", ->
      expr = @exp_pos_builder({variable: "funky"}, '=', {variable: 'chunky'})
      new_exp = @manip.build_remove_pointed_at().perform(expr)
      expected = @exp_builder({variable: "funky"}, '=')
      expect(new_exp.expression()).toBeAnEqualExpressionTo(expected)

  describe "utilities", ->
    describe "updating which element is pointed at", ->
      it "changes the place something is pointed at", ->
        pos_manip = @manip.utils.build_expression_position_manipulator()

        orig = @exp_pos_builder({variable: "funky"}, '=', {fraction: []})

        orig_pointed = orig.position()
        new_exp = pos_manip.updatePositionTo orig, (exp)->
          exp.isExpression() && exp.parent() && exp.parent().isFraction()
        expect(new_exp.position()).not.toEqual(orig_pointed)
        expect(new_exp.position()).toEqual(new_exp.expression().last().numerator().id())
