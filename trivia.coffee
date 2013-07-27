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

    clearTimeout @roundTimer if @roundTimer

  newQuestion: ->
    @cache['currentQuestion'] = questions[Math.floor(Math.random() * questions.length)]
    @robot.brain.data.trivia = @cache

    return @cache['currentQuestion']

  getQuestion: ->
    return @cache['currentQuestion']

  unsQuestion: ->
    delete @cache['currentQuestion']
    @robot.brain.data.trivia = @cache

  startRound: (envelope) ->
    trigger = =>
      @endRound envelope
    @roundTimer = setTimeout trigger, 2000

    @newQuestion()
    @robot.reply envelope, 'Round started. Current Question: ' + @getQuestion().question

  endRound: (envelope) ->
    @robot.reply envelope, 'Round finished'
    @roundTimer = clearTimeout @roundTimer if @roundTimer
    @unsQuestion()

  newRound: (envelope) ->
    if !@roundTimer
      @startRound envelope
    else
      @robot.reply envelope, 'Round active. Current Question: ' + @getQuestion().question

module.exports = (robot) ->
  Trivia = new TriviaGame robot
  #robot.respond /t/i, (msg) ->
  robot.hear /^q$/, (msg) -> # Temp to save typing out 'hubot t'
    if question = Trivia.getQuestion()
      msg.send question.question
    else
      msg.send 'There is not an active Trivia round'

  #robot.respond /t/i, (msg) ->
  robot.hear /^t$/, (msg) -> # Temp to save typing out 'hubot t'
    Trivia.newRound msg.envelope