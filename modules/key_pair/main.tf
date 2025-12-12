# --------------------------
# key Pair
# --------------------------

resource "aws_key_pair" "public" {
  key_name   = var.key_name
  public_key = file(var.key_pair_path)
}
