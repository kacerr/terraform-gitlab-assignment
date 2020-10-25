## Usage
1. have gitlab installation running somewhere
2. provide gitlab_token and gitlab_base_url somehow (TF_VAR_gitlab_token, -var, manual input, whatever ....)
3. run terraform
```
terraform init
terraform apply
```

## possible test scenario
```
- start gitlab in docker and somehow create and collect root token (maybe through rails console) (not simple)
- write & run unit test for terraform module
  - terratest
  - root token as parameter
  - somehow observe gitlab's state through api calls
  - conirm existence of stuff that is supposed to exist

```

## test usage
```
# go and tooling has to be installed
# i guess that go test itself collects required dependencies from the internet and then runs tests

cd tests
go test -timeout 30m
go test -v -timeout 30m # for "more" granular test results
```