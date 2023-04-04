""" Unit Test for lambda_function.py"""
from unittest import mock
import os
import json
import boto3
from moto import mock_dynamodb
import pytest
from lambda_function import lambda_handler


EVENT = ""
CONTEXT = ""

TB_NAME = "cloud-resume-visitor-count"


@pytest.fixture
def mock_settings_env_vars():
    """mock environment variable"""
    with mock.patch.dict(os.environ, {"table_name": TB_NAME}):
        yield


@pytest.fixture(name="use_moto")
def use_moto_fixture():
    """set up a mock dynamodb with item for testing"""

    @mock_dynamodb
    def dynamodb_client():
        dynamodb = boto3.client("dynamodb", region_name="ca-central-1")
        # Create the table
        dynamodb.create_table(
            TableName=TB_NAME,
            KeySchema=[
                {"AttributeName": "id", "KeyType": "HASH"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "id", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST",
        )
        # add the first record
        dynamodb.put_item(
            Item={
                "id": {
                    "S": "visitor",
                },
                "hits": {
                    "N": "40",
                },
            },
            TableName=TB_NAME,
        )
        dynamodb.get_item(
            Key={
                "id": {
                    "S": "visitor",
                },
            },
            TableName=TB_NAME,
        )
        return dynamodb

    return dynamodb_client


@mock_dynamodb
def test_handler_for_sucess(use_moto):
    """test lambda_handler with mock environment variable and mock dynamodb"""
    use_moto()

    return_data = lambda_handler(EVENT, CONTEXT)
    body = json.loads(return_data["body"])

    assert return_data["statusCode"] == 200
    assert body["message"] == "success"
    assert body["count"] == "41"


@pytest.fixture(name="use_moto_fake")
def use_moto_fake_fixture():
    """set up mock dynamodb which uses a wrong table"""

    @mock_dynamodb
    def dynamodb_client():
        dynamodb = boto3.client("dynamodb", region_name="ca-central-1")
        # Create the table
        dynamodb.create_table(
            TableName="fake",
            KeySchema=[
                {"AttributeName": "id", "KeyType": "HASH"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "id", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST",
        )
        # add the first record
        dynamodb.put_item(
            Item={
                "id": {
                    "S": "visitor",
                },
                "hits": {
                    "N": "40",
                },
            },
            TableName="fake",
        )
        dynamodb.get_item(
            Key={
                "id": {
                    "S": "visitor",
                },
            },
            TableName="fake",
        )
        return dynamodb

    return dynamodb_client


@mock_dynamodb
def test_handler_for_failure(use_moto_fake):
    """test lambda_handler with the mock dynamodb pointing to wrong table"""
    use_moto_fake()

    return_data = lambda_handler(EVENT, CONTEXT)

    assert return_data["statusCode"] == 500
