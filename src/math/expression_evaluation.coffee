# # Expression Evaluation

# A core feature of the library is the ability to
# "evaluate" expressions.
#
# For example, we might trivially evaluate an expression
# "1 + 2" to "3".



# make convenient aliases
ttm = thinkthroughmath
logger = ttm.logger
class_mixer = ttm.class_mixer
object_refinement = ttm.lib.object_refinement


# ## EvaluationRefinementBuilder
#
# Evaluation uses the refinement library from
# ttm-coffeescript-utils.
#
# Evaluation methods are added dynamically to expression components
# when they are needed.
class EvaluationRefinementBuilder
  initialize: (comps, class_mixer, object_refinement, MalformedExpressionError, precise)->
    comps = comps
    refinement = object_refinement.build()
    refinement.forType(comps.classes.number,
      {
        eval: ->
          @  # a number returns itself when it evaluates
      });

    refinement.forType(comps.classes.exponentiation,
      {
        eval: (evaluation, pass)->
          return if pass != "exponentiation"
          if !@base().isEmpty() && !@power().isEmpty()
            base = refinement.refine(@base()).eval().toCalculable()
            power = refinement.refine(@power()).eval().toCalculable()
            ttm.logger.info("exponentiation", base, power)
            comps.classes.number.build(value: Math.pow(base, power))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });

    refinement.forType(comps.classes.root,
      {
        eval: (evaluation, pass)->
          return if pass != "exponentiation"
          if @degree()? && @radicand()?
            degree = refinement.refine(@degree()).eval().toCalculable()
            radicand = refinement.refine(@radicand()).eval().toCalculable()
            ttm.logger.info("root", degree, radicand)
            comps.classes.number.build(value: Math.pow(radicand, 1 / degree))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });

    refinement.forType(comps.classes.pi,
      {
        eval: ->
          comps.classes.number.build(value: @value())
      });

    refinement.forType(comps.classes.addition,
      {
        eval: (evaluation, pass)->
          return if pass != "addition"

          prev = evaluation.previous()
          next = evaluation.next()
          if prev && next
            evaluation.handledSurrounding()
            comps.classes.number.build(value: precise.add(prev.value(), next.value()))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });

    refinement.forType(comps.classes.subtraction,
      {
        eval: (evaluation, pass)->
          return if pass != "addition"

          prev = evaluation.previous()
          next = evaluation.next()
          if prev && next
            evaluation.handledSurrounding()
            comps.classes.number.build(value: precise.sub(prev.value(), next.value()))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });


    refinement.forType(comps.classes.multiplication,
      {
        eval: (evaluation, pass)->
          return if pass != "multiplication"
          prev = evaluation.previous()
          next = evaluation.next()
          if prev && next
            evaluation.handledSurrounding()
            next = refinement.refine(next).eval(evaluation, pass).toCalculable()
            comps.classes.number.build(value: precise.mul(prev.value(), next))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });



    refinement.forType(comps.classes.division,
      {
        eval: (evaluation, pass)->
          return if pass != "multiplication"
          prev = evaluation.previous()
          next = evaluation.next()
          if prev && next
            evaluation.handledSurrounding()
            comps.classes.number.build(value: precise.div(prev.value(), next.value()))
          else
            throw new MalformedExpressionError("Invalid Expression")

      });

    refinement.forType(comps.classes.fraction,
      {
        eval: (evaluation, pass)->
          return if pass != "multiplication"
          num = refinement.refine(@numerator()).eval(evaluation, pass).toCalculable()
          denom = refinement.refine(@denominator()).eval(evaluation, pass).toCalculable()
          if num && denom
            comps.build_number(value: precise.div(num, denom))
          else
            throw new MalformedExpressionError("Invalid Expression")
      }
    )


    @refinement_val = refinement

    class ExpressionEvaluationPass
      initialize: (@expression)->
        @expression_index = -1

      perform: (pass_type)->
        ret = []

        @expression_index = 0
        while @expression.length > @expression_index
          exp = refinement.refine(@expression[@expression_index])
          eval_ret = exp.eval(@, pass_type)
          if eval_ret
            @expression[@expression_index] = eval_ret
          @expression_index += 1

        @expression

      previous: ->
        @expression[@expression_index - 1]

      next: ->
        @expression[@expression_index + 1]

      handledPrevious: ->
        @expression.splice(@expression_index - 1, 1)
        @expression_index -= 1

      handledSurrounding: ->
        @handledPrevious()
        @expression.splice(@expression_index + 1, 1)

    class_mixer(ExpressionEvaluationPass)

    refinement.forType(comps.classes.expression,
      {
        eval: ->
          expr = @expression
          logger.info("before parenthetical", expr)
          expr = ExpressionEvaluationPass.build(expr).perform("parenthetical")
          logger.info("before exponentiation", expr)
          expr = ExpressionEvaluationPass.build(expr).perform("exponentiation")
          logger.info("before multiplication", expr)
          expr = ExpressionEvaluationPass.build(expr).perform("multiplication")
          logger.info("before addition", expr)
          expr = ExpressionEvaluationPass.build(expr).perform("addition")
          logger.info("before returning", expr)

          # If expression does not contain a single item,
          # There was a problem with the expression
          if expr.length != 1
            throw new MalformedExpressionError("Invalid Expression")
          else
            _(expr).first()
      });


  refinement: ->
    @refinement_val

ttm.class_mixer EvaluationRefinementBuilder


# If the library receives an expression that it cannot evaluate, it will
# throw a MalformedExpressError
MalformedExpressionError = (message)->
  @name = 'MalformedExpressionError'
  @message = message
  @stack = (new Error()).stack
MalformedExpressionError.prototype = new Error;

comps = ttm.lib.math.ExpressionComponentSource.build()
class ExpressionEvaluation
  initialize: (@expression, @opts={})->
    @comps = @opts.comps || comps
    @precise = ttm.lib.math.Precise.build()
    @refinement = EvaluationRefinementBuilder.build(@comps, class_mixer, object_refinement, MalformedExpressionError, @precise).refinement()

  resultingExpression: ->
    @catchMalformedExpressionReturningError =>
      @comps.build_expression(expression: [@evaluate()])

  evaluate: ()->
    refined = @refinement.refine(@expression)
    refined.eval()

  catchMalformedExpressionReturningError: (fn)->
    results = false
    try
      results = fn()
    catch e
      throw e unless e instanceof MalformedExpressionError
    if results
      results
    else
      @comps.build_error()

class_mixer(ExpressionEvaluation)

ttm.lib.math.ExpressionEvaluation = ExpressionEvaluation
