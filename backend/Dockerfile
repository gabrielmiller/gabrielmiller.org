FROM golang:1.19.5-alpine as build
RUN apk add --no-cache git
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY . .

# These flags appear to be necessary for the scratch container
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

RUN go build -o .
RUN chmod +x blog

# deploy
FROM scratch
WORKDIR /app
COPY --from=build /app/blog .
EXPOSE 8080
CMD ["./blog"]