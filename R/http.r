# man 3 libcurl
# http://beders.github.com/Resty/Resty/Examples.html
# http://github.com/jnunemaker/httparty/tree/master

#' Get a url.
#'
#' \pkg{httr} automatically reuses the same http connection (aka handle)
#' for mulitple requests to the same scheme/host/port combo. This 
#' substantially reduces connection time, and ensures that cookies are 
#' maintained over multiple request to the same host. See
#' \code{\link{handle_pool}} for more details.
#'
#' @param handle the handle for the domain you're interested in
#' @param url the url of the page to retrieve
#' @param ... Further parameters, such as \code{query}, \code{path}, etc,
#'   passed on to \code{\link{modify_url}}. Typically used in conjunction
#'   with a specified \code{handle}. These parameter must be named.
#' @param handle The handle to use with this request. If not specified, the 
#'   same handle will be re-used for all request to the same combination
#'   of scheme (http or https), hostname and port.
#' @examples
#' GET("http://google.com/")
#'
#' GET("http://requestb.in/1ejpzfj1")
#'
#' # You might want to manually specify the handle so you can have multiple
#' # independent logins to the same website.
#' google <- handle("http://google.com")
#' GET(handle = google, path = "/")
GET <- function(url = NULL, ..., config = config(), handle = NULL) {
  hu <- handle_url(handle, url, ...)
  make_request("GET", hu$handle, hu$url, config = config)
}

handle_url <- function(handle = NULL, url = NULL, ...) {
  if (!xor(is.null(url), is.null(handle))) {
    stop("Must specify exactly one of url or handle")
  }

  if (is.null(handle))  handle <- find_handle(url)
  if (is.null(url))     url <- modify_url(handle$url, ...)

  list(handle = handle, url = url)
}

# Need to make it easy to upload files from local paths.
# Same for PUT
#' @inheritParams GET
POST <- function(url = NULL, params = NULL, ..., config = config(), handle = NULL) {
  hu <- handle_url(handle, url, ...)
  make_request("POST", hu$handle, hu$url, params = params, config = config)
}

HEAD <- function(url = NULL, params = NULL, ..., config = config(), handle = NULL) {
  hu <- handle_url(handle, url, ...)
  make_request("HEAD", hu$handle, hu$url, params = params, config = config)
}


# maybe need POST_file ?

PUT <- function(url, content, ...) {
  url <- modify_url(url, ...)
  getURLContent(url,
    customrequest = "PUT",
    postfields = content,
    postfieldsize = strlen(content)
  )
}


DELETE <- function(url, content, ...) {
  url <- modify_url(url, ...)
  getURLContent(url,
    customrequest = "DELETE",
    postfields = content,
    postfieldsize = strlen(content)
  )
}

# OPTIONS ? 
# PATCH ?

# curlPerform
# with_base_url(url, {})  
# with_base_url("http://google.com", {
#   with_base_url("/query.html", {
#     getURL(query = list())
#   })
#   
# })

# From Homer:
# POST_file <- function(file, ...){
#  with_body(slurp(file), {
#    with_headers(content-type="mulitpart/form-data", {
#      POST(...)
#    })
#  })
# }
# 
# The idea is that common (but not core) functionality like sending
# static files, HTTP authentication, or encoding as base 64 can be done
# once as 'middleware', which you can wrap around your existing code for
# making requests.
