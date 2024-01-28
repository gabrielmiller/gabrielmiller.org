import { Api, StackContext } from "sst/constructs";
import * as iam from "aws-cdk-lib/aws-iam";

export default {
    config(_input) {
        return {
            name: "serverless",
            profile: _input.stage,
            region: process.env.PRIVATE_S3_BUCKET_REGION
        };
    },
    stacks(app) {
        app.setDefaultFunctionProps({
            architecture: "arm_64",
            memorySize: 128,
            runtime: "go",
        });

        app.stack(function Stack({ stack }: StackContext) {
            const {
                FRONTEND_DOMAIN,
                PRIVATE_S3_BUCKET_NAME
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
                            PRIVATE_S3_BUCKET_NAME
                        }
                    }
                },
                routes: {
                    "GET /story": "functions/lambda/story.go",
                    "GET /entries": "functions/lambda/entries.go",
                },
            });

            api.attachPermissions([
                new iam.PolicyStatement({
                    actions: ["s3:GetObject"],
                    effect: iam.Effect.ALLOW,
                    resources: [
                        `arn:aws:s3:::${PRIVATE_S3_BUCKET_NAME}/*`
                    ]
                })
            ]);

            stack.addOutputs({
                ApiEndpoint: api.url,
            });
        });
    },
} satisfies SSTConfig;
