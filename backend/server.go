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
    http.HandleFunc("/story", getStoryHandler)
    http.HandleFunc("/entries", getEntriesHandler)

    log.Fatal(http.ListenAndServe(":" + os.Getenv("PORT"), nil))
}

func getStoryHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", os.Getenv("FRONTEND_DOMAIN"))

    username, password, ok := r.BasicAuth()

    if !ok {
        w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    Index, err := aws.GetIndexForStory(username, password)
    if (err != nil) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    json.NewEncoder(w).Encode(Index.Entries)
}

func getEntriesHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", os.Getenv("FRONTEND_DOMAIN"))

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

    data, err := aws.GetEntriesForStory(username, password, page, perPage)
    if (err != nil) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    json.NewEncoder(w).Encode(data)
}