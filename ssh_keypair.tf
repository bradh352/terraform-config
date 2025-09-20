resource "cloudstack_ssh_keypair" "brad" {
  name       = "brad"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUwODVaR5cV49C20XCZhWF+aPGwLuVdmxCgkjhwgWbs"
  project    = var.cloudstack_project
}
