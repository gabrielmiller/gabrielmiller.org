import { Api, StackContext } from "sst/constructs";
import * as iam from "aws-cdk-lib/aws-iam";

export default {
    config(_input) {
        return {
            name: "serverless",
            profile: _input.stage,
            region: process.env.ALBUM_BUCKET_REGION
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
                APEX_DOMAIN_ORIGIN,
                ALBUM_BUCKET
            } = process.env;

            const api = new Api(stack, "api", {
                cors: {
                    allowHeaders: ["authorization"],
                    allowMethods: ["GET"],
                    allowOrigins: [APEX_DOMAIN_ORIGIN],
                },
                defaults: {
                    function: {
                        environment: {
                            ALBUM_BUCKET
                        }
                    }
                },
                routes: {
                    "GET /album": "functions/lambda/album.go",
                    "GET /entries": "functions/lambda/entries.go",
                },
            });

            api.attachPermissions([
                new iam.PolicyStatement({
                    actions: ["s3:GetObject"],
                    effect: iam.Effect.ALLOW,
                    resources: [
                        `arn:aws:s3:::${ALBUM_BUCKET}/*`
                    ]
                })
            ]);

            stack.addOutputs({
                ApiEndpoint: api.url,
            });
        });
    },
} satisfies SSTConfig;
