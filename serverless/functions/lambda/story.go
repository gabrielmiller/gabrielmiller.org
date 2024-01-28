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
    unauthorized_response := events.APIGatewayProxyResponse{
        Body: "Unauthorized",
        StatusCode: 404,
    };

    authHeader, exists := request.Headers["authorization"]
    if !exists {
        return unauthorized_response, nil
    }

    headerParts := strings.Split(authHeader, " ")

    if len(headerParts) != 2 {
        return unauthorized_response, nil
    }

    decodedHeader, err := base64.StdEncoding.DecodeString(headerParts[1])
    if err != nil {
        return unauthorized_response, nil
    }

    parsedHeaderParts := strings.Split(string(decodedHeader), ":")
    if len(parsedHeaderParts) != 2 {
        return unauthorized_response, nil
    }

    Index, err := aws.GetIndexForStory(parsedHeaderParts[0], parsedHeaderParts[1])
    if err != nil {
        return unauthorized_response, nil
    }

    Entries, err := json.Marshal(Index.Entries)
    if err != nil {
        return unauthorized_response, nil
    }

    return events.APIGatewayProxyResponse{
        Body: string(Entries),
        StatusCode: 200,
    }, nil
}

func main() {
    lambda.Start(Handler)
}
