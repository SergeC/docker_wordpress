vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "nginx";
    .port = "80";
}

# process client request
sub vcl_recv {
    # Don't cache POST-requests and Basic-auth
    if (req.http.Authorization || req.method == "POST") {
        return (pass);
    }

    # Don't cache admin panel requests
    if (req.url ~ "wp-(login|admin)" || req.url ~ "preview=true") {
        return (pass);
    }

    # Cache everything else
    return (hash);
}

sub vcl_pass {
    return (fetch);
}

sub vcl_hash {
    hash_data(req.url);
    return (lookup);
}

# Process back end response
sub vcl_backend_response {
    # Don't cache responses without HTTP 200 code
    if ( beresp.status != 200 ) {
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return (deliver);
    }

    # Keep responses in cache for one day
    set beresp.ttl = 1d;
    # Keep responses for 30 seconds after TTL expire
    set beresp.grace = 30s;
    return (deliver);
}

# Set header before send response
sub vcl_deliver {
   if (obj.hits > 0) {
     set resp.http.X-Cache = "HIT";
   } else {
     set resp.http.X-Cache = "MISS";
   }
   return (deliver);
}