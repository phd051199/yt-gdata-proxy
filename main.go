package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/ping", ping)
	http.HandleFunc("/", proxy)

	http.ListenAndServe(":3000", nil)
}
