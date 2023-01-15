package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"
    "blog/aws"
)

type Entry struct {
    Description string `json:"description"`
    Url string `json:"url"`
}

func main() {
    http.HandleFunc("/", indexHandler)
    http.HandleFunc("/b", bucketFileListingHandler)

    log.Fatal(http.ListenAndServe(":" + os.Getenv("PORT"), nil))
}

func indexHandler(w http.ResponseWriter, _ *http.Request) {
    e := Entry{Description:"Sample entry", Url:"https://www.google.com"}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(e)
}

func bucketFileListingHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    filesInBucket := aws.GetIndexForStory("test-album")

    json.NewEncoder(w).Encode(filesInBucket)
}