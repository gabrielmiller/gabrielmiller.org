import { SSTConfig } from "sst";
import { API } from './stacks/API';

export default {
    config(_input) {
        return {
            name: "serverless",
            profile: _input.stage,
            region: "us-east-2",
        };
    },
    stacks(app) {
        app.setDefaultFunctionProps({
            runtime: "go",
        });

        app.stack(API);
    },
} satisfies SSTConfig;
