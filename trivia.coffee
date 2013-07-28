# Description:
#   An action packed game of Trivia
#
# Commands:
#   hubot trivia - Begins a round of Trivia
#   hubot q[uestion] - Return the current question
#   hubot h[int] - Get a hint for the current question
#   * - Answer a question

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
      question: "A sidewinder is what type of creature?"
      answer: "Snake"
    }
    {
      question: "A Harlequin is what type of bird?"
      answer: "Duck"
    }
    {
      question: "A Saki is what type of animal?"
      answer: "Monkey"
    }
    {
      question: "This Flightless Bird lays the World's largest Eggs?"
      answer: "Ostrich"
    }
    {
      question: "The Offspring of a male donkey and a female horse is called what?"
      answer: "Mule"
    }
    {
      question: "An octopus has how many hearts?"
      answer: "3"
    }
    {
      question: "A lepidopterist collects?"
      answer: "Butterflies and moths"
    }
    {
      question: "Cashmere is sourced from which animal?"
      answer: "Goat"
    }
    {
      question: "The staple diet of a Koala bear is what?"
      answer: "Eucalyptus Leaves"
    }
    {
      question: "What creature was Will Smith's codename in the movie Independence day?"
      answer: "Eagle"
    }
    {
      question: "What type of animal according to Beatrix Potter was Mr Jeremy Fisher?"
      answer: "Frog"
    }
    {
      question: "What is the only mammal that can't jump?"
      answer: "Elephant"
    }
    {
      question: "What kind of animal mates only once for 12 hours and can sleep for three years?"
      answer: "Snail"
    }
    {
      question: "A Quagga is an extinct animal that was a distant cousin to which animal that exists today?"
      answer: "Zebra"
    }
    {
      question: "The study of birds eggs is called what?"
      answer: "Oology"
    }
  ]
}

class Question
  constructor: (@questionData) ->

  question: ->
    return @questionData.question

  answer: ->
    return @questionData.answer

  answerHint: ->
    return @answer().replace /[a-zA-Z0-9]/g, '_'

  # cant seem to get propertyMissing & __noSuchMethod__ to work...

class Round
  constructor: (@robot, @envelope, @question) ->

  start: (roundTime) ->
    trigger = =>
      @end()
    @roundTimer = setTimeout trigger, roundTime

    @robot.reply @envelope, 'Round started. Current Question: ' + @question.question()

  end: (winner = false) ->
    if !winner
      @robot.reply @envelope, 'Round finished - no one guessed the answer correctly!'
    else
      @robot.reply @envelope, 'Round finished'
    @roundTimer = clearTimeout @roundTimer if @roundTimer
    delete @question

  isInProgress: ->
    return if @roundTimer then true else false

class TriviaGame
  constructor: (@robot, @data) ->

  newQuestion: ->
    questionData = @data.questions[Math.floor(Math.random() * @data.questions.length)]
    @question = new Question questionData

  newRound: (envelope) ->
    if !@round or !@round.isInProgress()
      @round = new Round @robot, envelope, @newQuestion()
      @round.start @data.configuration.roundTime
    else
      @robot.reply envelope, 'Round active. Current Question: ' + @round.question.question()

  declareWinner: (envelope, name) ->
    @robot.reply envelope, 'Congratulations ' + name + ' - you guessed correctly! The answer was: ' + @round.question.answer()
    @round.end true

module.exports = (robot) ->
  Trivia = new TriviaGame robot, TriviaData

  robot.respond /q[uestion]?/i, (msg) ->
    if Trivia.round and question = Trivia.round.question
      msg.send 'Current Question: ' + question.question()
    else
      msg.send 'There is not an active Trivia round'

  robot.respond /h[int]?/i, (msg) ->
    if Trivia.round and question = Trivia.round.question
      msg.send 'Answer Hint: ' + question.answerHint()
    else
      msg.send 'There is not an active Trivia round'

  robot.respond /trivia?/i, (msg) ->
    Trivia.newRound msg.envelope

  robot.hear /^([\s\S]*)$/, (msg) ->
    if Trivia.round and Trivia.round.isInProgress()
      guess = msg.match[1].toLowerCase()
      answer = Trivia.round.question.answer().toLowerCase()
      if guess == answer
        Trivia.declareWinner msg.envelope, msg.message.user.name
