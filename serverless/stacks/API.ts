import { Api, StackContext } from "sst/constructs";

export const API = function Stack({ stack }: StackContext) {
    const {
        FRONTEND_DOMAIN,
        PRIVATE_S3_BUCKET_ACCESS_KEY_ID,
        PRIVATE_S3_BUCKET_NAME,
        PRIVATE_S3_BUCKET_SECRET_ACCESS_KEY
    } = process.env;

    const api = new Api(stack, "api", {
        cors: {
            allowHeaders: ["authorization"],
            allowMethods: ["GET"],
            allowOrigins: [FRONTEND_DOMAIN],
        },
        defaults: {
            function: {
                environment: {
                    FRONTEND_DOMAIN,
                    PRIVATE_S3_BUCKET_SECRET_ACCESS_KEY,
                    PRIVATE_S3_BUCKET_ACCESS_KEY_ID,
                    PRIVATE_S3_BUCKET_NAME
                }
            }
        },
        routes: {
            "GET /story": "functions/lambda/story.go",
            "GET /entries": "functions/lambda/entries.go",
        },
    });

    stack.addOutputs({
        ApiEndpoint: api.url,
    });
}