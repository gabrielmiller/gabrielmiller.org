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

    // default to page 1 and a sane page size
    page, err := strconv.Atoi(request.QueryStringParameters["page"])
    if err != nil {
        page = 1
    }

    perPage, err := strconv.Atoi(request.QueryStringParameters["perPage"])
    if err != nil {
        perPage = 12
    }

    if (page < 1) {
        page = 1
    }

    if (perPage > 64 || perPage < 1) {
        perPage = 12
    }

    data, err := aws.GetEntriesForAlbum(parsedHeaderParts[0], parsedHeaderParts[1], page, perPage)
    if err != nil {
        return unauthorized_response, nil
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
