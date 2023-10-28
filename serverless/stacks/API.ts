import { Api, StackContext } from "sst/constructs";

export const API = function Stack({ stack }: StackContext) {
    const api = new Api(stack, "api", {
      cors: {
        allowHeaders: ['authorization'],
        allowMethods: ["GET"],
        allowOrigins: [process.env.FRONTEND_DOMAIN],
      },
      defaults: {
        function: {
            environment: {
                PRIVATE_S3_BUCKET_NAME: process.env.S3_BUCKET_NAME
            }
        }
      },
      routes: {
        "GET /": "functions/lambda/list.go",
        "GET /{id}": "functions/lambda/detail.go",
      },
    });

    stack.addOutputs({
      ApiEndpoint: api.url,
    });
}