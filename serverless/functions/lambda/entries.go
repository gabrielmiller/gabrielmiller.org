package main

import (
    "encoding/base64"
    "encoding/json"
    "github.com/aws/aws-lambda-go/events"
    "github.com/aws/aws-lambda-go/lambda"
    "main/aws"
    "strconv"
    "strings"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
    authHeader, exists := request.Headers["authorization"]
    if !exists {
        return events.APIGatewayProxyResponse{
            Body: "Unauthorized",
            StatusCode: 404,
        }, nil
    }

    headerParts := strings.Split(authHeader, " ")

    if len(headerParts) != 2 {
        return events.APIGatewayProxyResponse{
            Body: "Unauthorized",
            StatusCode: 404,
        }, nil
    }

    decodedHeader, err := base64.StdEncoding.DecodeString(headerParts[1])
    if err != nil {
        return events.APIGatewayProxyResponse{
            Body: "Unauthorized",
            StatusCode: 404,
        }, nil
    }

    parsedHeaderParts := strings.Split(string(decodedHeader), ":")
    if len(parsedHeaderParts) != 2 {
        return events.APIGatewayProxyResponse{
            Body: "Unauthorized",
            StatusCode: 404,
        }, nil
    }

    // default to page 1 and a sane page size
    page, err := strconv.Atoi(request.QueryStringParameters["page"])
    if err != nil {
        page = 1
    }

    perPage, err := strconv.Atoi(request.QueryStringParameters["perPage"])
    if err != nil {
        perPage = 4
    }

    if (page < 1) {
        page = 1
    }

    if (perPage > 10 || perPage < 1) {
        perPage = 4
    }

    data, err := aws.GetEntriesForStory(parsedHeaderParts[0], parsedHeaderParts[1], page, perPage)
    if err != nil {
        return events.APIGatewayProxyResponse{
            Body: "Unauthorized",
            StatusCode: 404,
        }, nil
    }

    headers := make(map[string]string)
    headers["Content-Type"] = "application/json"

    presignedUrls := new(strings.Builder)
    json.NewEncoder(presignedUrls).Encode(data)

    return events.APIGatewayProxyResponse{
        Body: presignedUrls.String(),
        Headers: headers,
        StatusCode: 200,
    }, nil
}

func main() {
    lambda.Start(Handler)
}
