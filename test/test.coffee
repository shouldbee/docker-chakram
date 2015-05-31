chakram = require('chakram')
expect = chakram.expect
describe 'HTTP assertions', ->
  it 'should make HTTP assertions easy', ->
    response = chakram.get('http://httpbin.org/get?test=chakram')
    expect(response).to.have.status 200
    expect(response).to.have.header 'content-type', 'application/json'
    expect(response).not.to.be.encoded.with.gzip
    expect(response).to.comprise.of.json args: test: 'chakram'
    chakram.wait()

