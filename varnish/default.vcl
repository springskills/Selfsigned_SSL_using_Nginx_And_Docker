vcl 4.1;

backend default {
.host = "127.0.0.1";
.port = "8888";
}

# access control list for "purge": open to only localhost and other local nodes
acl purge {
 "localhost";
 "127.0.0.1";
 "::1";
}


# vcl_recv is called whenever a request is received
sub vcl_recv {
# Serve objects up to 2 minutes past their expiry if the backend
# is slow to respond.
# set req.grace = 120s;

set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;

set req.backend_hint= default;

# This uses the ACL action called "purge". Basically if a request to
# PURGE the cache comes from anywhere other than localhost, ignore it.
if (req.method == "PURGE") {
	if (!client.ip ~ purge) {
		return (synth(405, "Not allowed."));
	} else {
		return (purge);
}
}



# Cache this file types
   if (req.url ~ "^[^?]*\.(gzip|ico|html|7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
#       unset req.http.Cookie;
       return(hash);
   }



# Pass special pages in persian
if (req.url ~ "title=ویژه"){
	return (pass);
}

# Pass if user has logged in
if(req.http.Cookie ~ "new_wiki_session"){
	return (pass);
}

# Pass requests from logged-in users directly.
# Only detect cookies with "session" and "Token" in file name, otherwise nothing get cached.
#if (req.http.Authorization || req.http.Cookie ~ "([sS]ession|Token)=") {
#	return (pass);
#} /* Not cacheable by default */

# normalize Accept-Encoding to reduce vary
if (req.http.Accept-Encoding) {
if (req.http.User-Agent ~ "MSIE 6") {
unset req.http.Accept-Encoding;
} elsif (req.http.Accept-Encoding ~ "gzip") {
set req.http.Accept-Encoding = "gzip";
} elsif (req.http.Accept-Encoding ~ "deflate") {
set req.http.Accept-Encoding = "deflate";
} else {
unset req.http.Accept-Encoding;
}
}


return (hash);
}

sub vcl_pipe {
# Note that only the first request to the backend will have
# X-Forwarded-For set. If you use X-Forwarded-For and want to
# have it set for all requests, make sure to have:
# set req.http.connection = "close";

# This is otherwise not necessary if you do not do any request rewriting.

set req.http.connection = "close";
}

# Called if the cache has a copy of the page.
sub vcl_hit {
if (!obj.ttl > 0s) {
return (pass);
}
}

# Called after a document has been successfully retrieved from the backend.
sub vcl_backend_response {
# Don't cache 50x responses
if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
set beresp.uncacheable = true;
return (deliver);
}

if (beresp.ttl < 48h) {
set beresp.ttl = 48h;
}

if (!beresp.ttl > 0s) {
set beresp.uncacheable = true;
return (deliver);
}

if (beresp.http.Set-Cookie) {
set beresp.uncacheable = true;
return (deliver);
}

if (beresp.http.Authorization && !beresp.http.Cache-Control ~ "public") {
set beresp.uncacheable = true;
return (deliver);
}


# Set ttl for cached file types

    if (bereq.url ~ "^[^?]*\.(gzip|ico|html|7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
#        unset beresp.http.Set-Cookie;
        set beresp.ttl = 2d;
    }

    if (beresp.http.Content-Type ~ "text") {
        set beresp.ttl = 2d;
    }



return (deliver);
}


sub vcl_deliver {
# Happens when we have all the pieces we need, and are about to send the
# response to the client.
#
# You can do accounting or modifying the final object here.


# Add debug header to see if it's a HIT/MISS and the number of hits, disable when not needed
if (obj.hits > 0) {
set resp.http.Varnish-Cache = "HIT - Varnish";
} else {
set resp.http.Varnish-Cache = "MISS - Varnish";
}




# For debugging only.
# The approximate number of times the object has been delivered. A value of 0 indicates a cache miss.
set resp.http.X-obj-hits = obj.hits;
}
