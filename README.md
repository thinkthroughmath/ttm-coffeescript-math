# TTM Coffeescript Math

### Docker Container
Start an instance of a node Docker container and run all these commands inside

This assumes you are using SSH keys for github access. If not, you will need to get your Github credentials into the container in order for the bower step to work.
```
docker run --rm -it -v ~/.ssh:/root/.ssh:ro -v `pwd`:/srv/ttm-coffeescript-math -w /srv/ttm-coffeescript-math node:0.10 bash
```

### Initial Setup

    npm install
    npm install bower grunt-cli@1.2

    ./node_modules/.bin/bower --allow-root install

### To serve library in a browser

    ./node_modules/.bin/grunt serve

### To run tests

    ./node_modules/.bin/grunt test

### To build as package to commit as a release

    ./node_modules/.bin/grunt build
