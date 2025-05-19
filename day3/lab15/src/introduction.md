# An Introduction to Service Mesh

## A simple Web UI: videos-web

* this is NOT a production ready APP 
* This is used for Microservice DEMO / Service Mesh Demo
* All DB are redis ( for Training and Demo )

<hr/>
<br/>

`videos-web` <br/>
It's an HTML application that lists a bunch of playlists with videos in them.

```
+------------+
| videos-web |
|            |
+------------+
```
<br/>

## A simple API: playlists-api
<hr/>
<br/>

For `videos-web` to get any content, it needs to make a api call to `playlists-api`

```
+------------+     +---------------+
| videos-web +---->+ playlists-api |
|            |     |               |
+------------+     +---------------+

```

Playlists consist of data like `title`, `description` etc, and a list of `videos`. <br/>
Playlists are stored in a database. <br/>
`playlists-api` stores its data in a database

```
+------------+     +---------------+    +--------------+
| videos-web +---->+ playlists-api +--->+ playlists-db |
|            |     |               |    |              |
+------------+     +---------------+    +--------------+

```

<br/>

## A little complexity - to Simulate Service Mesh
<hr/>
<br/>

Each playlist item contains only a list of video id's. <br/>
A playlist does not have the full metadata of each video. <br/>

Example `playlist`:
```
{
  "id" : "playlist-01",
  "title": "Cool playlist",
  "videos" : [ "video-1", "video-x" , "video-b"]
}
```
Take note above `videos: []` is a list of video id's <br/>

Videos have their own `title` and `description` and other metadata. <br/>

To get this data, we need a `videos-api` <br/>
This `videos-api` has its own database too <br/>

```
+------------+       +-----------+
| videos-api +------>+ videos-db |
|            |       |           |
+------------+       +-----------+
```

For the `playlists-api` to load all the video data, it needs to call `videos-api` for each video ID it has.<br/>
<br/>

## Traffic flow
<hr/>
<br/>
A single `GET` request to the `playlists-api` will get all the playlists 
from its database with a single DB call <br/>

For every playlist and every video in each list, a separate `GET` call will be made to the `videos-api` which will
retrieve the video metadata from its database. <br/>

This will result in many network fanouts between `playlists-api` and `videos-api` and many call to its database. <br/>
This is intentional to demonstrate a busy network.

<br/>

## Full application architecture
<hr/>
<br/>

```

+------------+     +---------------+    +--------------+
| videos-web +---->+ playlists-api +--->+ playlists-db |
|            |     |               |    |              |
+------------+     +-----+---------+    +--------------+
                         |
                         v
                   +-----+------+       +-----------+
                   | videos-api +------>+ videos-db |
                   |            |       |           |
                   +------------+       +-----------+

```

## Adding an Ingress Controller

Adding an ingress controller allows us to route all our traffic. </br>
We setup a `host` file with entry `127.0.0.1  mesh.stux.dom.io`
And `port-forward` to the `ingress-controller`


```
mesh.stux.dom.io/home --> videos-web
mesh.stux.dom.io/api/playlists --> playlists-api


                              mesh.stux.dom.io/home/           +--------------+
                              +------------------------------> | videos-web   |
                              |                                |              |
mesh.stux.dom.io/home/ +------+------------+                   +--------------+
   +------------------>+ingress-nginx      |
                       |Ingress controller |
                       +------+------------+                   +---------------+    +--------------+
                              |                                | playlists-api +--->+ playlists-db |
                              +------------------------------> |               |    |              |
                              mesh.stux.dom.io/api/playlists   +-----+---------+    +--------------+
                                                                     |
                                                                     v
                                                               +-----+------+       +-----------+
                                                               | videos-api +------>+ videos-db |
                                                               |            |       |           |
                                                               +------------+       +-----------+




```