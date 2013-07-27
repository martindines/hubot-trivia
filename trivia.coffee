# Description:
#   An action packed game of Trivia
#
# Commands:
#   hubot command - Description

TriviaData = {
  configuration: {
    roundTime: 10000
  }

  questions: [
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
}

class TriviaGame

  constructor: (@robot, @data) ->
    @cache = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.trivia
        @cache = @robot.brain.data.trivia

    @roundTimer = clearTimeout @roundTimer if @roundTimer

  newQuestion: ->
    @cache['currentQuestion'] = @data.questions[Math.floor(Math.random() * @data.questions.length)]
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
    @roundTimer = setTimeout trigger, @data.configuration.roundTime

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
  Trivia = new TriviaGame robot, TriviaData
  #robot.respond /t/i, (msg) ->
  robot.hear /^q$/, (msg) -> # Temp to save typing out 'hubot t'
    if question = Trivia.getQuestion()
      msg.send 'Current Question: ' + question.question
    else
      msg.send 'There is not an active Trivia round'

  #robot.respond /t/i, (msg) ->
  robot.hear /^t$/, (msg) -> # Temp to save typing out 'hubot t'
    Trivia.newRound msg.envelope