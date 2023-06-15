# Relational Algebra Interpretor

To run the interpretor within a docker container, clone the repository,
`cd` into the repo directory, and run the following:

```
docker build -t rel-alg .
docker run --network=host -v $(pwd)/data:/rel-alg/data rel-alg
```

The web interface will be available at http://127.0.0.1:4567
