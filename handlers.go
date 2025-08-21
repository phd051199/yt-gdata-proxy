package main

import (
	"context"
	"errors"
	"net/http"
	"net/http/httputil"
)

const (
	statusOk         = "status=ok"
	fwdDomain        = "s60tube.io.vn"
	youtubeHost      = "www.youtube.com"
	gdataHost        = "gdata.youtube.com"
	getVideoInfoPath = "/get_video_info"
	getVideoPath     = "/get_video"
)

var (
	ok  = []byte(statusOk)
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
	case youtubeHost:
		switch path {
		case getVideoInfoPath:
			w.Write(ok)
			return
		case getVideoPath:
			http.Redirect(w, req, "http://"+fwdDomain+"/videoplayback?v="+req.URL.Query().Get("video_id"), http.StatusFound)
			return
		}
	case gdataHost:
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
