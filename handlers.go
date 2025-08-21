package main

import (
	"net/http"

	"github.com/vulcand/oxy/v2/forward"
)

var (
	ok        = []byte("status=ok")
	fwdDomain = "s60tube.io.vn"
	fwd       = forward.New(false)
)

func proxy(w http.ResponseWriter, req *http.Request) {
	host := req.Host
	path := req.URL.Path

	switch host {
	case "www.youtube.com", "youtube.com", "m.youtube.com":
		switch path {
		case "/get_video_info":
			w.Write(ok)
			return
		case "/get_video":
			http.Redirect(w, req, "http://"+fwdDomain+"/videoplayback?v="+req.URL.Query().Get("video_id"), http.StatusFound)
			return
		}
	case "gdata.youtube.com":
		req.URL.Host = fwdDomain
		req.Host = fwdDomain
		fwd.ServeHTTP(w, req)
		return
	}

	fwd.ServeHTTP(w, req)
}

func ping(w http.ResponseWriter, req *http.Request) {
	w.Write(ok)
}
