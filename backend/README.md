### Current development flow
_Current versions locally are: ubuntu 20.04, go1.19.5 linux/amd64, docker 19.03.13, build 4484c46d9d._
 - If working in docker:
   - First blow away all cache with `docker system prune --all`
   - Then rebuild the container and run it with `docker-compose up`
     - `-d` if you want to daemonize
 - If working locally:
   - `go build .` in the working dir
   - then `./blog`
   - I have not yet accounting for ENV vars in this workflow
 - Leaning toward putting secrets in environment vars since that should "just work" for the aws libs?

### To-do list
 - docker compose override seems to not work as expected. _Maybe this is something about docker compose vs docker-compose? Their docs make it look like the .override file should automatically work out..._
 - outbound AWS request in container doesn't work
   - should test if this works locally if I set the variables. If it does, probably a docker issue. If it doesn't, gotta tinker with the sourcecode more.
 - Figure out a logical way to break up this code up into packages
 - Figure out where to ideally put secrets
 - Create separate HTTP endpoints for:
   - authentication/index of a gallery
   - fetch page n of a gallery

### Plan of attack
 - HTTP Request flow
   - Frontend makes a request w/ basic auth, for the story index
   - The response tells if auth was valid and the number of entries in the index
   - Frontend then makes requests when necessary to get paginated pre-signed entries
     - Frontend says "page y, 10 per page"
       -   Might be worth looking into a library for pagination?
   - API translates to the proper slice of the index, for each entry it reaches out to s3 to presign the url
     - it returns an array of the entries
     - each contains the presigned url and arbitrary metadata

 - Index file
   - There will be a build process to...
     1. upload images/videos to the story
       - Can specify if it should blow away the current contents or not
       - Can specify if it should blow away the current index or not
     2. build an index file for a story
       - This will just be a json array with space for arbitrary metadata on each record. It will be manually edited to add that metadata.
       - Because the frontend reads from the index file it will need to be updated if files are added or removed, or to update metadata.