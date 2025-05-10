# Relational Algebra Interpreter

Developed for [National University of Kyiv-Mohyla Academy](https://www.ukma.edu.ua/eng/)

## How to Run

To run the interpreter, clone the repository,
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

The web interface will be available at http://127.0.0.1:4567.

Or, alternatively:

```
docker-compose down
docker-compose up -d --build
```

In this case, the web interface will be available at http://127.0.0.1:4568.


## Syntax

The supported operators are:
- set union `∪` (aliased as `|`)
- set intersection `∩` (aliased as `&`)
- set difference `\`
- Cartesian product `×` (aliased as `*`)
- projection `R[a]`
- selection `R[a=x]`
- join `R1[a=b]R2` (note: natural join operator `๐` is supported as well)
- division `R1[a1÷a2]R2` (aliased as `R1[a1/a2]R2`)

To write the result of an operation into a relation, use `⟶` (aliased as `->`).

Comments `//` are also supported.

## Development & Testing

To run the tests locally:

```
bundle exec rspec -fd
bundle exec cucumber
```
