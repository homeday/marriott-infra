# Standard root terragrunt entrypoint
# Child configs can include this file via find_in_parent_folders()
include "root" {
  path = "${get_terragrunt_dir()}/root.hcl"
}
