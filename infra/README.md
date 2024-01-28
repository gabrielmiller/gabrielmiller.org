# Initial setup

There are a couple pieces of my infrastructure that are not yet codified in terraform. Until it's all there, the following steps detail manual interventions that are necessary.

_Note that I have defined infrastructure for staging and production environments. If you have more environments you will need to define them similar to the staging and production directories. The examples below are referencing production, but you should be able to simplify switch to staging by referencing its directory. You will need to follow all steps for each environment._

1. Create the resources in question
    - Create a wildcard https cert for your domain. I use certbot and letsencrypt, though am going to explore ways to do it through terraform in the future.
    - Upload your wildcard cert into ACM in your desired AWS region. Note its ARN.
    - Upload your wildcard cert into ACM in us-east-1. Note its ARN.
    - I already had cloudflare dns records configured prior to switching over to terraform. I didn't explicitly test creating them from scratch but I believe what's configured in here ought to do it for you. If not, manually create CNAME records on www and your apex domain pointed at anything initially. Record the zone and id of the dns records.

2. Create your `variables.tfvars` file in the environment's directory.
    - Add values for `cloudflare_account_id`, `cloudflare_api_token`, and `cloudflare_zone_id`. If you have not created a cloudflare token to manage your DNS records, you should do that first.
    - Update the domain and bucket names in `variables.tf` to match your desired names.

3. Initialize terraform
```
terraform -chdir=./production init -var-file=./variables.tfvars
```

4. Manually import the resources from step 1 above.

```
terraform -chdir=./production import -var-file=./variables.tfvars module.cloudflare_apex_dns.cloudflare_record.apex <zone_id>/<record_id>
terraform -chdir=./production import -var-file=./variables.tfvars module.cloudflare_www_dns.cloudflare_record.www <zone_id>/<record_id>
terraform -chdir=./production import -var-file=variables.tfvars 'module.acm_certificate_cloudfront.aws_acm_certificate.wildcard' <arn of us-east-1 cert>
terraform -chdir=./production import -var-file=variables.tfvars 'module.acm_certificate_api_gateway.aws_acm_certificate.wildcard' <arn of desired region cert>
```

5. Create a plan and run it to stand up the rest of the infrastructure

```
terraform -chdir=./production plan -var-file=./variables.tfvars -out changes
terraform -chdir./production apply changes
```