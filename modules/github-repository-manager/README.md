# Github Repository Manager

## Update the README

```bash
terraform-docs md tbl --output-mode inject --output-file=README.md 
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_branch.development](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch) | resource |
| [github_branch_protection.development](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_branch_protection.master](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | the name of the gitignore to use, all list in https://github.com/github/gitignore | `string` | n/a | yes |
| <a name="input_repository_description"></a> [repository\_description](#input\_repository\_description) | Small description of the repository | `string` | n/a | yes |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | The name of github repository | `string` | n/a | yes |
| <a name="input_visibility_mode"></a> [visibility\_mode](#input\_visibility\_mode) | The visibility of the repository, accept private or public | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_project_url"></a> [github\_project\_url](#output\_github\_project\_url) | n/a |
<!-- END_TF_DOCS -->