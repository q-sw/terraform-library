variable "repository_name"{
	type = string
	description = "The name of github repository"
}

variable "repository_description" {
	type = string
	description = "Small description of the repository"
}

variable "visibility_mode" {
	type = string
	description = "The visibility of the repository, accept private or public"
	validation {
		condition = contains(["private", "public"], var.visibility_mode)
		error_message = "Visibility_mode value is incorrect choose one of private ,public."
	}
}

variable "gitignore_template" {
	type = string
	description = "the name of the gitignore to use, all list in https://github.com/github/gitignore"
}
