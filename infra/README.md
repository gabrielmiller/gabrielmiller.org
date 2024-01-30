# Important things to know

There are a couple pieces of my infrastructure that are not yet codified in terraform. Until it's all there, the following steps detail manual interventions that are necessary.

I have defined infrastructure for staging and production environments. If you have more environments you will need to define them similar to the staging and production directories. The examples below are referencing production, but you should be able to switch to staging by using its directory. You will need to follow all steps for each environment.

I am using aws profiles to authenticate and I'm using a different for each environment. I also am using a separate aws account for each environment, however you can configure this however you please by adjusting where your local aws profiles go.

There is some infrastructure that managed outside of terraform, through [sst](https://sst.dev/), which is used to create backend functionality for the album viewer. That code manages api gateway, lambda, associated iam profiles, and miscellaneous related resources.

# Initial setup

Configure your AWS profiles if you have not yet done so. You can read about this [here](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html). When you're done you should have a configuration in `~/.aws/config` that resembles the following:
```
[default]
region = us-east-2

[sso-session gabe]
sso_start_url = <redacted>
sso_region = us-east-2

[profile staging]
sso_session = gabe
sso_account_id = <redacted>
sso_role_name = AdministratorAccess

[profile production]
sso_session = gabe
sso_account_id = <redacted>
sso_role_name = AdministratorAccess
```

# Initial setup for each environment

1. Create the resources in question
    - Create a wildcard https cert for your domain. I use certbot and letsencrypt, though am going to explore ways to do it through terraform in the future.
    - In the proper aws account/region, upload your wildcard cert into ACM. Note its ARN.
    - In the proper aws account _in us-east-1_, upload your wildcard cert into ACM. Note its ARN. _Cloudfront can only use us-east-1. If you're already using us-east-1 you probably should just consolidate these two configurations into one, which will require updating the terraform configuration._
    - I already had cloudflare dns records configured prior to using terraform. I didn't explicitly test creating them from scratch but I believe what's configured in here ought to do it for you. If not, manually create CNAME records on `www` and the apex domain pointed at anything initially. Record the zone and id each dns record. _You can inspect the DOM to extract the id of the record._

2. Create and adjust variables in the environment directory.
    - First, create a `variables.tfvars` file. Inside of it set values for `cloudflare_account_id`, `cloudflare_api_token`, and `cloudflare_zone_id`. If you have not created a cloudflare token to manage your DNS records, you should do that first. [This document](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) may be a useful reference. This token will need permission to edit DNS records in your zone.
    - Next, update the domain and bucket name variable default values defined in `variables.tf` to match your desired values.

3. Authenticate with your aws profile. In the root directory you can run the `./blog.sh` script which has a helper to do this for you.

4. Initialize terraform
```
terraform -chdir=./production init -var-file=./variables.tfvars
```

5. Manually import the resources from step 1 above.
```
terraform -chdir=./production import -var-file=./variables.tfvars module.cloudflare_apex_dns.cloudflare_record.apex <zone_id>/<record_id>
terraform -chdir=./production import -var-file=./variables.tfvars module.cloudflare_www_dns.cloudflare_record.www <zone_id>/<record_id>
terraform -chdir=./production import -var-file=./variables.tfvars 'module.acm_certificate_cloudfront.aws_acm_certificate.wildcard' <arn of us-east-1 cert>
terraform -chdir=./production import -var-file=./variables.tfvars 'module.acm_certificate_api_gateway.aws_acm_certificate.wildcard' <arn of desired region cert>
```

6. Create a plan and run it to stand up the rest of the infrastructure
```
terraform -chdir=./production plan -var-file=./variables.tfvars -out changes
terraform -chdir./production apply changes
```