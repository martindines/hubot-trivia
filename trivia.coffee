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
    @unsQuestion()

  isRoundInProgress: ->
    return if @roundTimer then true else false

  newQuestion: ->
    @cache['currentQuestion'] = @data.questions[Math.floor(Math.random() * @data.questions.length)]
    @robot.brain.data.trivia = @cache

    return @cache['currentQuestion']

  getQuestion: ->
    if @cache['currentQuestion']
      return @cache['currentQuestion'].question

  getAnswer: ->
    if @cache['currentQuestion']
      return @cache['currentQuestion'].answer

  getAnswerHint: ->
    if @cache['currentQuestion']
      return @getAnswer().replace /[a-zA-Z]/g, '_'

  unsQuestion: ->
    delete @cache['currentQuestion']
    @robot.brain.data.trivia = @cache

  startRound: (envelope) ->
    trigger = =>
      @endRound envelope
    @roundTimer = setTimeout trigger, @data.configuration.roundTime

    @newQuestion()
    @robot.reply envelope, 'Round started. Current Question: ' + @getQuestion()

  endRound: (envelope, winner = false) ->
    if !winner
      @robot.reply envelope, 'Round finished - no one guessed the answer correctly!'
    else
      @robot.reply envelope, 'Round finished'
    @roundTimer = clearTimeout @roundTimer if @roundTimer
    @unsQuestion()

  newRound: (envelope) ->
    if !@roundTimer
      @startRound envelope
    else
      @robot.reply envelope, 'Round active. Current Question: ' + @getQuestion()

  declareWinner: (envelope, name) ->
    @robot.reply envelope, 'Congratulations ' + name + ' - you guessed correctly! The answer was: ' + @getAnswer()
    @endRound envelope, true

module.exports = (robot) ->
  Trivia = new TriviaGame robot, TriviaData
  robot.respond /q[uestion]?/i, (msg) ->
    if question = Trivia.getQuestion()
      msg.send 'Current Question: ' + question
    else
      msg.send 'There is not an active Trivia round'

  robot.respond /h[int]?/i, (msg) ->
    if answerHint = Trivia.getAnswerHint()
      msg.send 'Answer Hint: ' + Trivia.getAnswerHint()
    else
      msg.send 'There is not an active Trivia round'

  robot.respond /trivia?/i, (msg) ->
    Trivia.newRound msg.envelope

  robot.hear /^([\s\S]*)$/, (msg) ->
    if Trivia.isRoundInProgress()
      guess = msg.match[1].toLowerCase()
      answer = Trivia.getAnswer().toLowerCase()
      if guess == answer
        Trivia.declareWinner msg.envelope, msg.message.user.name
