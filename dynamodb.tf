resource "aws_dynamodb_table" "ddbtable" {
  name         = var.dynamodb_table_name
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  tags = local.tags
}

resource "aws_dynamodb_table_item" "ddbtable_item" {
  table_name = aws_dynamodb_table.ddbtable.name
  hash_key   = aws_dynamodb_table.ddbtable.hash_key

  item = <<ITEM
{
  "id": {
    "S": "visitor"
  },
  "hits": {
    "N": "0"
  }
}
ITEM
}
