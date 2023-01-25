package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"
    "strconv"
    "blog/aws"
)

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
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode("hello")
}

func storyIndexHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    index, _ := aws.GetIndexForStory("test")

    var Index aws.StoryIndex
    json.Unmarshal([]byte(index), &Index)
    json.NewEncoder(w).Encode(Index)
}

func presignFileHandler(w http.ResponseWriter, _ *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    url, _ := aws.GetPresignUrl("test", "0001.jpg")

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

    // default to page 1 and a sane page size
    page, err := strconv.Atoi(r.FormValue("page"))
    if err != nil {
        page = 1
    }

    perPage, err := strconv.Atoi(r.FormValue("perPage"))
    if err != nil {
        perPage = 4
    }

    if (page < 1) {
        page = 1
    }

    if (perPage > 10 || perPage < 1) {
        perPage = 4
    }

    data, err := aws.GetEntriesForStoryByPage(username, password, page, perPage)
    if (err != nil) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    json.NewEncoder(w).Encode(data)
}