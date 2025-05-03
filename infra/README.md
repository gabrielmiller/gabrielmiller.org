# Important things to know

All infrastructure is codified with terraform configuration.

There are two environments configured: staging and production. I've opted to model this as two different directories that share the same modules in order to apply changes to staging and production independent of one another. If you have more environments you will need to define them similar to the staging and production directories.

The example commands below are referencing production, but you should be able to switch to staging by using its directory. You will need to follow all steps for each environment.

I am using aws profiles to authenticate and I'm using a different for each environment. I also am using a separate aws account for each environment, however you can configure this however you please by adjusting where your local aws profiles go.

# Initial setup

Configure your AWS profiles if you have not yet done so. You can read about this [here](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html). When you're done you should have a configuration in `~/.aws/config` that resembles the following:
```ini
[default]
region = us-east-2

[sso-session gabe]
sso_start_url = <redacted>
sso_region = us-east-2

[profile personal-staging]
sso_session = gabe
sso_account_id = <redacted>
sso_role_name = AdministratorAccess
sso_start_url = <redacted>
sso_region = us-east-2

[profile personal-production]
sso_session = gabe
sso_account_id = <redacted>
sso_role_name = AdministratorAccess
sso_start_url = <redacted>
sso_region = us-east-2
```

_The redundant regions and start_url on the profiles appear to be necessary, but I'm not sure why_.

# Initial setup for each environment

1. Create and adjust variables in the environment directory.
    - First, create a `variables.tfvars` file. Inside of it set values for `cloudflare_account_id`, `cloudflare_api_token`, and `cloudflare_zone_id`. If you have not created a cloudflare token to manage your DNS records, you should do that first. [This document](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) may be a useful reference. This token will need permission to edit DNS records in your zone.
    - Next, update the domain and bucket name variable default values defined in `variables.tf` to match your desired values.

2. Authenticate with your aws profile. In the root directory you can run the `./blog.sh` script which has a helper to do this for you.

3. Initialize terraform
```sh
terraform -chdir=./production init -var-file=./variables.tfvars
```

4. Create a plan and run it to stand up the rest of the infrastructure
```sh
terraform -chdir=./production plan -var-file=./variables.tfvars -out changes
terraform -chdir=./production apply changes
```
