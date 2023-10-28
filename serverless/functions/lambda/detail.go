package main

import (
	"encoding/base64"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"main/aws"
	"strings"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	headerParts := strings.Split(request.Headers["authorization"], " ")

	if len(headerParts) != 2 {
		return events.APIGatewayProxyResponse{
			Body: "invalid auth header: bad format",
			StatusCode: 404,
		}, nil
	}

	decodedHeader, err := base64.StdEncoding.DecodeString(headerParts[1])
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body: "invalid auth header: could not decode base64",
			StatusCode: 404,
		}, nil
	}

	parsedHeaderParts := strings.Split(string(decodedHeader), ":")
	if len(parsedHeaderParts) != 2 {
		return events.APIGatewayProxyResponse{
			Body: "invalid auth header: bad format",
			StatusCode: 404,
		}, nil
	}

	Index, err := aws.GetIndexForStory(parsedHeaderParts[0], parsedHeaderParts[1])
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body: "story not found",
			StatusCode: 404,
		}, err
	}

	Entries, err := json.Marshal(Index.Entries)
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body: "Could not decode entries",
			StatusCode: 404,
		}, nil
	}

	return events.APIGatewayProxyResponse{
		Body: string(Entries),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
