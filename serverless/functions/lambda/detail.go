package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		Body:       "Response from detail view at " + request.RequestContext.Time + " with authorization header " + request.Headers["authorization"] + " and this lambda function was subsequently updated after creation!",
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
