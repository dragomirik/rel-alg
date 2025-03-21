# Relational Algebra Interpretor

Developed for [National University of Kyiv Mohyla Academy](https://www.ukma.edu.ua/eng/)

## How to Run

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

## How to Use

The supported operators are:
- set union `∪` (aliased as `|`)
- set intersection `∩` (aliased as `&`)
- set difference `\`
- Cartesian product `×` (aliased as `*`)
- projection `R[a]`
- selection `R[a=x]`
- join `R1[a=b]R2`
- division `R1[a1÷a2]R2` (aliased as `R1[a1/a2]R2`)

To write the result of an operation into a relation, use `⟶` (aliased as `->`).

## Development & Testing

To run the tests localy:

```
bundle exec rspec -fd
bundle exec cucumber
```
