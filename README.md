# Relational Algebra Interpretor

To run the interpretor, clone the repository,
`cd` into the repo directory, and run the following commands:

```
bundle install
ruby main.rb
```

Or, alternatively, if you want to run it within a docker container:

```
docker build -t rel-alg .
docker run --network=host -v $(pwd)/data:/rel-alg/data rel-alg
```

The web interface will be available at http://127.0.0.1:4567

## Development & Testing

To run the tests localy:

```
bundle exec rspec -fd
bundle exec cucumber
```
