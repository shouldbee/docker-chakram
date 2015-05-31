chakram = require('chakram')
expect = chakram.expect

describe 'Random User API', ->
  apiResponse = undefined

  before ->
    apiResponse = chakram.get('http://api.randomuser.me/?gender=female')
    return

  it 'should return 200 on success', ->
    expect(apiResponse).to.have.status 200

  it 'should return content type and server headers', ->
    expect(apiResponse).to.have.header 'server'
    expect(apiResponse).to.have.header 'content-type', /json/
    chakram.wait()

  it 'should include email, username, password and phone number', ->
    expect(apiResponse).to.have.schema 'results[0].user', 'required': [
      'email'
      'username'
      'password'
      'phone'
    ]

  it 'should return a female user', ->
    expect(apiResponse).to.have.json 'results[0].user.gender', 'female'

  it 'should return a valid email address', ->
    expect(apiResponse).to.have.json (json) ->
      email = json.results[0].user.email
      expect(/\S+@\S+\.\S+/.test(email)).to.be.true
      return

  it 'should return a single random user', ->
    expect(apiResponse).to.have.schema 'results',
      minItems: 1
      maxItems: 1

  it 'should not be gzip compressed', ->
    expect(apiResponse).not.to.be.encoded.with.gzip

  it 'should return a different username on each request', ->
    @timeout 10000
    multipleResponses = []
    ct = 0
    while ct < 5
      multipleResponses.push chakram.get('http://api.randomuser.me/?gender=female')
      ct++
    chakram.all(multipleResponses).then (responses) ->
      returnedUsernames = responses.map((response) ->
        response.body.results[0].user.username
      )
      while returnedUsernames.length > 0
        username = returnedUsernames.pop()
        expect(returnedUsernames.indexOf(username)).to.equal -1
