# Assignment for [REDACTED]

This repository contains the completed assignment for the [REDACTED] role at [REDACTED].

## License

All contents of this repository are copyright of the author and may not be reproduced.

## Development

The code was developed in a standard macOS environment with these Homebrew packages and versions:

* `awscli` 2.1.28
* `terraform` 0.14.7

## Instructions

Make sure you have all the right tools installed, credentials loaded, variables set, etc. Then:
```console
cd terraform
terraform init
terraform apply
```

Fetch the kubeconfig for the new cluster using the AWS CLI:
```console
aws eks update-kubeconfig --name assignment
```
