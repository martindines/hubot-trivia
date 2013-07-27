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
      question: "A mandrill is what type of creature?"
      answer: "Monkey"
    }
    {
      quesiton: "A sidewinder is what type of creature?"
      answer: "Snake"
    }
    {
      quesiton: "A Harlequin is what type of bird?"
      answer: "Duck"
    }
    {
      quesiton: "A Saki is what type of animal?"
      answer: "Monkey"
    }
    {
      quesiton: "This Flightless Bird lays the World's largest Eggs?"
      answer: "Ostrich"
    }
    {
      quesiton: "The Offspring of a male donkey and a female horse is called what?"
      answer: "Mule"
    }
    {
      quesiton: "An octopus has how many hearts?"
      answer: "3"
    }
    {
      quesiton: "A lepidopterist collects?"
      answer: "Butterflies and moths"
    }
    {
      quesiton: "Cashmere is sourced from which animal?"
      answer: "Goat"
    }
    {
      quesiton: "The staple diet of a Koala bear is what?"
      answer: "Eucalyptus Leaves"
    }

    {
      quesiton: "What creature was Will Smith's codename in the movie Independence day?"
      answer: "Eagle"
    }
    {
      quesiton: "What type of animal according to Beatrix Potter was Mr Jeremy Fisher?"
      answer: "Frog"
    }
    {
      quesiton: "What is the only mammal that can't jump?"
      answer: "Elephant"
    }
    {
      quesiton: "What kind of animal mates only once for 12 hours and can sleep for three years?"
      answer: "Snail"
    }
    {
      quesiton: "A Quagga is an extinct animal that was a distant cousin to which animal that exists today?"
      answer: "Zebra"
    }
    {
      quesiton: "The study of birds eggs is called what?"
      answer: "Oology"
    }
    {
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
