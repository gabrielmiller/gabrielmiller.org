# About

_McRib is back! New looks, same great Gabe._

## Goals

The intent of this site is to reboot my blogging efforts while introducing new capabilities. My old blog was entirely publicly accessible static content.

I've been sharing an annual newsletter through email with a bunch of photos. I started thinking that it would be good for me to build my own private photo sharing capability so I'm not beholden to google photos. Further, now that I have a blog again, maybe I'll actually write some content sometimes.

My design goals are as follows:
 - Allow for blog entries to be accessible either publicly or privately. Further, I want the photo/video/other assets to follow the expected access restrictions of the associated entry: users without authorization should not be able to guess a URL to get at private content.
 - Minimize maintenance and financial costs. I would prefer to run this thing without a backend but I haven't come up with a way to avoid it given my requirement above.

## How-to

### How does this thing work?

The entry-point into everything is through the `blog.sh` script in the root. Run `./blog.sh` and have at it.

### Environment configuration

This project relies upon you having a handful of AWS configurations in place:
 - S3 bucket to serve public content
 - S3 bucket to serve private content
 - Cloudfront distributions for s3 buckets on apex domain and `www` subdomain
 - ACM to apply a wildcard https certificate to cloudfront distributions.
 - Credentials for an ec2 instance to run a backend.

The credentials for each of these things should be configured ideally as separate IAM user credentials for each service/access level in isolation:
 - write access on the privately accessible S3 bucket:
   - `s3:DeleteObject`
   - `s3:ListBucket`
   - `s3:PutObject`
 - read access on the privately accessible S3 bucket:
   - `s3:GetObject`
   - `s3:ListBucket`
 - write access on the publicly accessible S3 bucket:
   - `s3:DeleteObject`
   - `s3:ListBucket`
   - `s3:PutObject`
 - the ability to import a cert into acm:
   - `acm:ImportCertificate`
 - the ability to generate a certificate with certbot's DNS challenge through route53:
   - `route53:GetChange`
   - `route53:ChangeResourceRecordSets`
   - `route53:ListHostedZones`

 I've extracted these credentials into environment variables in non-committed files named `.env.staging` and `.env.production`. These live in each of the following directories:
    - `backend` - credentials for read access on the privately accessible s3 bucket, ec2 ssh access, tls certificate local paths, paths to various things inside ec2 instance, supporting properties for api.
    - `cert` - credentials for access to import certificates to acm. Additionally the paths of the certs certbot generates by default and the ARN of the certificate in question.
    - `dns` - credentials for certbot to complete the dns challenge to generate a wildcard tls certificate. Additionally, the domain names to provide certbot, and the email address to use with the registration.
    - `frontend` - credentials for write access on the publicly accessible static content s3 bucket and cloudfront caching configuration.
    - `stories` - credentials for write access on the privately accessible image s3 bucket.