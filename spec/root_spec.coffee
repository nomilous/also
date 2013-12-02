root   = require '../lib/root'
should = require 'should'

describe 'root', -> 

    it 'returns the root object containing the "home" directory', -> 

        root().home.should.match /also$/
