# Local development

Until I clean stuff up, here's how to do dev on the gatsby-based blog:

```sh
docker run --rm --mount type=bind,src=".",dst="/project" -w /project -p 8000:8000 -it node:24-alpine sh
npm install
npm run build -w blog
# maybe build some other workspaces
npm run develop
```

And here's a one-liner for building:
```sh
docker run --rm --mount type=bind,src=".",dst="/project" -w /project -p 8000:8000 node:24-alpine sh -c "npm install && npm run build -w blog"
```