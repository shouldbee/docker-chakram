# docker-chakram

[Chakram] is REST API test framework. This is a docker image that eases setup.

## About Chakram

> Chakram is an API testing framework designed to perform end to end tests on JSON REST endpoints. The library offers a BDD testing style and fully exploits javascript promises - the resulting tests are simple, clear and expressive. The library is built on [node.js](https://nodejs.org/), [mocha](http://mochajs.org/) and [chai](http://chaijs.com/).

From: [dareid/chakram](https://github.com/dareid/chakram)

## Install

This docker image is available as an automated build on [the docker registry hub](https://registry.hub.docker.com/u/shouldbee/chakram/), so using it is as simple as running:


```console
$ docker run shouldbee/chakram
```

To further ease running, it's recommended to set up a much shorter function so that you can easily execute it as just `chakram`:

```
$ chakram () {
  sudo docker run -it --rm --net host -v `pwd`:/wd -w /wd shouldbee/chakram "$@"
}
```

This will create a temporary function. In order to make it persist reboots, you can append this exact line to your `~/.bashrc` (or similar) like this:

```console
$ declare -f chakram >> ~/.bashrc
```

## Usage

```console
$ mkdir test
$ $EDITOR test/test.js

var chakram = require('chakram'),
    expect = chakram.expect;

describe("HTTP assertions", function () {
  it("should make HTTP assertions easy", function () {
    var response = chakram.get("http://httpbin.org/get?test=chakram");
    expect(response).to.have.status(200);
    expect(response).to.have.header("content-type", "application/json");
    expect(response).not.to.be.encoded.with.gzip;
    expect(response).to.comprise.of.json({
      args: { test: "chakram" }
    });
    return chakram.wait();
  });
});

$ chakram

  HTTP assertions
    ✓ should make HTTP assertions easy (563ms)


  1 passing (570ms)
```

See [official site](http://dareid.github.io/chakram/) for more information.


[Chakram]: http://dareid.github.io/chakram/
