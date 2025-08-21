package main

import (
	"net/http"
	"strings"

	"github.com/vulcand/oxy/v2/forward"
)

var (
	ok        = []byte("status=ok")
	fwdDomain = "s60tube.io.vn"
	fwd       = forward.New(false)
)

func handler(w http.ResponseWriter, req *http.Request) {
	path := req.URL.Path
	host := req.Host
	urlStr := req.URL.String()

	if path == "/" {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(ok)
		return
	}

	if strings.Contains(host, "youtube.com") {
		switch {
		case strings.Contains(urlStr, "/get_video_info"):
			w.Header().Set("Content-Type", "application/atom+xml")
			_, _ = w.Write(ok)
			return

		case strings.Contains(urlStr, "/get_video"):
			target := "http://" + fwdDomain + "/videoplayback?v=" + req.URL.Query().Get("video_id")
			http.Redirect(w, req, target, http.StatusFound)
			return

		case strings.Contains(urlStr, "gdata.youtube.com"):
			req.URL.Host = fwdDomain
			req.Host = fwdDomain
			fwd.ServeHTTP(w, req)
			return
		}
	}

	// Default forward
	fwd.ServeHTTP(w, req)
}

func main() {
	http.ListenAndServe(":3000", http.HandlerFunc(handler))
}
