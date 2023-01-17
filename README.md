# About

_McRib is back! New looks, same great Gabe._

## Goals

The intent of this new blog is to reboot my blogging efforts while introducing new capabilities. My old blog was purely static content and it had no level of access control to content. I had been sharing an annual newsletter through email and figured it would be a good candidate to share through a website. Further, maybe I'll actually write some content beyond just an annual update.

My design goals are as follows:
 - Allow for blog entries to be accessible either publicly or privately. Further, I want the photo/video/other assets to follow the expected access restrictions of the associated entry: users without authorization should not be able to guess a URL to get at them.
 - Reduce maintenance and financial costs to a minimum. I would prefer to run this thing without a backend but it seems like a necessity given my requirement above. I've tried to cut as much as possible. My backend serves as an HTTP server that interacts with AWS S3 buckets. That's it.

## How-to

### How does this thing work?

The entry-point into everything is through the `blog.sh` script in the root. Give it a `./blog.sh` and have at it.

### Environment configuration

This project relies upon you having several things configured in AWS, namely S3 buckets and IAM credentials/roles. I've extracted those credentials into non-committed files. I will further document these things as this project gets closer to its first production release, but here's a running list:

1. Two S3 buckets: one for publicly accessible static content and one for privately accessible images. _I made two sets of these buckets, one set for staging and one set for production._

2. Create IAM role(s) and user(s) with the following privileges
    - for write access on the privately accessible image bucket(s):
        - `s3:DeleteObject`
        - `s3:ListBucket`
        - `s3:PutObject`
    - for read access on the privately accessible image bucket(s):
        - `s3:GetObject`
        - `s3:ListBucket`
    - for write access on the publicly accessible static content bucket
        - `s3:DeleteObject`
        - `s3:ListBucket`
        - `s3:PutObject`

3. I chose to make a separate role and user for each permutation, but that's not a necessity. You should put these in the files named as follows:
    - `.env.dev`
    - `.env.staging`
    - `.env.production`
In the following directories:
    - `backend` - credentials for read access on the _privately accessible image bucket._
    - `frontend` - credentials for write access on the _publicly accessible static content bucket._
    - `stories` - credentials for write access on the _privately accessible image bucket._