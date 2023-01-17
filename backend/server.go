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
    http.HandleFunc("/story", getStoryHandler)
    http.HandleFunc("/entries", getEntriesHandler)

    log.Fatal(http.ListenAndServe(":" + os.Getenv("PORT"), nil))
}

func indexHandler(w http.ResponseWriter, _ *http.Request) {
    e := Entry{Description:"Sample entry", Url:"https://www.google.com"}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(e)
}

func storyIndexHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    index, _ := aws.GetIndexForStory("test")

    var jsonMap map[string]interface{}
    json.Unmarshal([]byte(index), &jsonMap)
    json.NewEncoder(w).Encode(jsonMap)
}

func presignFileHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    url := aws.GetPresignUrl("test", "0001.jpg")

    json.NewEncoder(w).Encode(url)
}

func bucketFileListingHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    filesInBucket := aws.ListBucketContents()

    json.NewEncoder(w).Encode(filesInBucket)
}

func getStoryHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    username, password, ok := r.BasicAuth()

    if !ok {
        w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    index, err := aws.GetIndexForStory(username)
    if (err != nil) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    var jsonMap map[string]interface{}
    json.Unmarshal([]byte(index), &jsonMap)

    if (jsonMap["accessToken"] != password) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    json.NewEncoder(w).Encode(jsonMap["entries"])
}

func getEntriesHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    username, password, ok := r.BasicAuth()

    if !ok {
        w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    index, err := aws.GetIndexForStory(username)
    if (err != nil) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    var jsonMap map[string]interface{}
    json.Unmarshal([]byte(index), &jsonMap)

    if (jsonMap["accessToken"] != password) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    // Get pagination info from somewhere and passs it into an s3 api request
}