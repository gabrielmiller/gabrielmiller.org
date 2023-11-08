package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"os"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		Body:       "Response from list view at " + request.RequestContext.Time + " for bucket " + os.Getenv("PRIVATE_S3_BUCKET_NAME") + ".",
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
