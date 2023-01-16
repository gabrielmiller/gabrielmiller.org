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
    http.HandleFunc("/i", storyIndexHandler)
    http.HandleFunc("/p", presignFileHandler)

    log.Fatal(http.ListenAndServe(":" + os.Getenv("PORT"), nil))
}

func indexHandler(w http.ResponseWriter, _ *http.Request) {
    e := Entry{Description:"Sample entry", Url:"https://www.google.com"}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(e)
}

func storyIndexHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    index := aws.GetIndexForStory("test-album")

    var jsonMap map[string]interface{}
    json.Unmarshal([]byte(index), &jsonMap)
    json.NewEncoder(w).Encode(jsonMap)
}

func presignFileHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    url := aws.GetPresignUrl("test-album", "0001.jpg")

    json.NewEncoder(w).Encode(url)
}

func bucketFileListingHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    filesInBucket := aws.ListBucketContents()

    json.NewEncoder(w).Encode(filesInBucket)
}