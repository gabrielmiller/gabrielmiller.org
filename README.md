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

This project relies upon you having several things configured in AWS, namely S3 buckets and IAM credentials/roles. I've extracted those into non-committed files. I will further document these things as this project gets closer to its first production release.