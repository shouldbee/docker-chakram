chakram = require('chakram')
expect = chakram.expect

describe 'Spotify API', ->
  before ->
    spotifyErrorSchema =
      properties: error:
        properties:
          status: type: 'integer'
          message: type: 'string'
        required: [
          'status'
          'message'
        ]
      required: [ 'error' ]
    chakram.addProperty 'spotify', ->
    chakram.addMethod 'error', (respObj, status, message) ->
      expect(respObj).to.have.schema spotifyErrorSchema
      expect(respObj).to.have.status status
      expect(respObj).to.have.json 'error.message', message
      expect(respObj).to.have.json 'error.status', status

    chakram.addMethod 'limit', (respObj, topLevelObjectName, limit) ->
      expect(respObj).to.have.schema topLevelObjectName,
        required: [
          'limit'
          'items'
        ]
        properties:
          limit:
            minimum: limit
            maximum: limit
          items:
            minItems: limit
            maxItems: limit

  describe 'Search Endpoint', ->
    randomArtistSearch = undefined

    before ->
      randomArtistSearch = chakram.get('https://api.spotify.com/v1/search?q=random&type=artist')

    it 'should require a search query', ->
      missingQuery = chakram.get('https://api.spotify.com/v1/search?type=artist')
      expect(missingQuery).to.be.a.spotify.error 400, 'No search query'

    it 'should require an item type', ->
      missingType = chakram.get('https://api.spotify.com/v1/search?q=random')
      expect(missingType).to.be.a.spotify.error 400, 'Missing parameter type'

    shouldSupportItemType = (type) ->
      it 'should support item type ' + type, ->
        typeCheck = chakram.get('https://api.spotify.com/v1/search?q=random&type=' + type)
        expect(typeCheck).to.have.status 200

    shouldSupportItemType 'artist'
    shouldSupportItemType 'track'
    shouldSupportItemType 'album'
    shouldSupportItemType 'playlist'

    it 'should throw an error if an unknown item type is used', ->
      missingType = chakram.get('https://api.spotify.com/v1/search?q=random&type=invalid')
      expect(missingType).to.be.a.spotify.error 400, 'Bad search type field'

    it 'should by default return 20 search results', ->
      expect(randomArtistSearch).to.have.limit 'artists', 20

    it 'should support a limit parameter', ->
      one = chakram.get('https://api.spotify.com/v1/search?q=random&type=artist&limit=1')
      expect(one).to.have.limit 'artists', 1
      fifty = chakram.get('https://api.spotify.com/v1/search?q=random&type=artist&limit=50')
      expect(fifty).to.have.limit 'artists', 50
      chakram.wait()

    it 'should support an offset parameter', ->
      first = chakram.get('https://api.spotify.com/v1/search?q=random&type=artist&limit=1')
      second = chakram.get('https://api.spotify.com/v1/search?q=random&type=artist&limit=1&offset=1')
      expect(first).to.have.json 'artists.offset', 0
      expect(second).to.have.json 'artists.offset', 1
      chakram.all([
        first
        second
      ]).then (responses) ->
        expect(responses[0].body.artists.items[0].id).not.to.equal responses[1].body.artists.items[0].id
        chakram.wait()

    it 'should only support GET calls', ->
      @timeout 4000
      expect(chakram.post('https://api.spotify.com/v1/search')).to.have.status 405
      expect(chakram.put('https://api.spotify.com/v1/search')).to.have.status 405
      expect(chakram.delete('https://api.spotify.com/v1/search')).to.have.status 405
      expect(chakram.patch('https://api.spotify.com/v1/search')).to.have.status 405
      chakram.wait()

    it 'should return href, id, name and popularity for all found artists', ->
      expect(randomArtistSearch).to.have.schema 'artists.items',
        type: 'array'
        items:
          type: 'object'
          properties:
            href: type: 'string'
            id: type: 'string'
            name: type: 'string'
            popularity: type: 'integer'
          required: [
            'href'
            'id'
            'name'
            'popularity'
          ]
