import { SSTConfig } from "sst";
import { Api } from "sst/constructs";

export default {
  config(_input) {
    return {
      name: "serverless",
      profile: _input.stage === "production" ? "production" : "development",
      region: "us-east-2",
    };
  },
  stacks(app) {
    app.setDefaultFunctionProps({
      runtime: "go",
    });
    app.stack(function Stack({ stack }) {
      const api = new Api(stack, "api", {
        routes: {
          "GET /": "functions/lambda/list.go",
          "GET /{id}": "functions/lambda/detail.go",
        },
      });
      stack.addOutputs({
        ApiEndpoint: api.url,
      });
    });
  },
} satisfies SSTConfig;
