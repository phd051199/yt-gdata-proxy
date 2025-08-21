package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/ping", ping)
	http.HandleFunc("/", proxy)

	http.ListenAndServe(":10000", nil)
}
