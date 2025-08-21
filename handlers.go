package main

import (
	"context"
	"errors"
	"net/http"
	"net/http/httputil"
)

const (
	fwdDomain = "s60tube.io.vn"
)

var (
	ok  = []byte("status=ok")
	fwd = &httputil.ReverseProxy{
		Director: func(r *http.Request) {},
		ErrorHandler: func(w http.ResponseWriter, r *http.Request, err error) {
			if errors.Is(err, context.Canceled) {
				return
			}
		},
	}
)

func proxy(w http.ResponseWriter, req *http.Request) {
	host := req.Host
	path := req.URL.Path

	switch host {
	case "www.youtube.com":
		switch path {
		case "/get_video_info":
			w.Write(ok)
			return
		case "/get_video":
			http.Redirect(w, req, "http://"+fwdDomain+"/videoplayback?v="+req.URL.Query().Get("video_id"), http.StatusFound)
			return
		}
	case "gdata.youtube.com":
		req.Header.Add("X-Forwarded-For", req.RemoteAddr)
		req.Host = fwdDomain
		req.URL.Host = fwdDomain
		fwd.ServeHTTP(w, req)
		return
	}
	fwd.ServeHTTP(w, req)
}

func ping(w http.ResponseWriter, req *http.Request) {
	w.Write(ok)
}
