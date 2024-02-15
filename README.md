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

The entry-point into common operations is the `blog.sh` script in the root directory. Run it without args to get a list of options.

### Infrastructure

There's a separate README under the `infra` directory with details about how to stand up the necessary infrastructure.