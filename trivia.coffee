# Description:
#   An action packed game of Trivia
#
# Commands:
#   hubot command - Description

questions = [
  {
    id: 1
    question: "A mandrill is what type of creature?"
    answer: "Monkey"
  }
  {
    id: 2
    question: "Who is the best?"
    answer: "Martin"
  }
]

class TriviaGame

  constructor: (@robot) ->
    @cache = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.trivia
        @cache = @robot.brain.data.trivia

  getQuestion: ->
    if !@cache['currentQuestion']
      @cache['currentQuestion'] = questions[Math.floor(Math.random() * questions.length)]
      @robot.brain.data.trivia = @cache

    return @cache['currentQuestion']

module.exports = (robot) ->
  Trivia = new TriviaGame robot
  #robot.respond /q/i, (msg) ->
  robot.hear /^q$/, (msg) -> # Temp to save typing out 'hubot q'
    question = Trivia.getQuestion()
    msg.send 'Current Question: ' + question.question + ' Current Answer: ' + question.answer