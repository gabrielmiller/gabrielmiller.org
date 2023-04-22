package main

import (
    "crypto/tls"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "strconv"
    "blog/aws"
)

func main() {
    fmt.Println("Running server")
    mux := http.NewServeMux()
    mux.HandleFunc("/story", getStoryHandler)
    mux.HandleFunc("/entries", getEntriesHandler)

    server := &http.Server{
        Addr: ":"+os.Getenv("PORT"),
        Handler: mux,
        TLSConfig: &tls.Config{
            MinVersion: tls.VersionTLS13,
            PreferServerCipherSuites: true,
        },
    }

    log.Fatal(server.ListenAndServeTLS(os.Getenv("TLS_CHAIN_CERT"), os.Getenv("TLS_PRIVATE_KEY")))
}


func getStoryHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Access-Control-Allow-Origin", os.Getenv("FRONTEND_DOMAIN"))
    fmt.Println("handling story request")
    if r.Method == http.MethodOptions {
        fmt.Println("1");
        w.Header().Set("Access-Control-Allow-Methods", "GET")
        w.Header().Set("Access-Control-Allow-Headers", "authorization")
        return
    }

    if r.Method != http.MethodGet {
        fmt.Println("2");
        w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    w.Header().Set("Content-Type", "application/json")

    username, password, ok := r.BasicAuth()

    if !ok {
        fmt.Println("3");
        w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    Index, err := aws.GetIndexForStory(username, password)
    if (err != nil) {
        fmt.Println("4");
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    json.NewEncoder(w).Encode(Index.Entries)
}

func getEntriesHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Access-Control-Allow-Origin", os.Getenv("FRONTEND_DOMAIN"))

    if r.Method == http.MethodOptions {
        w.Header().Set("Access-Control-Allow-Methods", "GET")
        w.Header().Set("Access-Control-Allow-Headers", "authorization")
        return
    }

    if r.Method != http.MethodGet {
        w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

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

    data, err := aws.GetEntriesForStory(username, password, page, perPage)
    if (err != nil) {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    json.NewEncoder(w).Encode(data)
}