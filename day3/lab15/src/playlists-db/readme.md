
# Let’s build a **custom Redis image** called `stv707/playlistdb:v1`, based on `redis:6.0-alpine`, with a valid, Redis-generated `appendonly.aof` preloaded.

---

## ✅ OVERVIEW

We’ll:

1. Start a Redis container with AOF enabled
2. Inject the playlist data using `redis-cli`
3. Trigger Redis to write a clean `appendonly.aof`
4. Copy that file out
5. Build a Docker image with that file embedded
6. Tag and push as `stv707/playlistdb:v1`

---

## 🔨 STEP 1: Start a Redis container with AOF enabled

```bash
docker run -d --name redis-playlist-tmp \
  -p 6380:6379 \
  redis:6.0-alpine \
  redis-server --appendonly yes
```

---

## 📝 STEP 2: Inject your playlist data into Redis

```bash
docker exec -it redis-playlist-tmp redis-cli
```

Paste this:

```redis
SET playlists "[{\"id\":\"1\",\"name\":\"Kubernetes\",\"videos\":[{\"id\":\"FmLna7tHDRc\"},{\"id\":\"nRVBNkcr4eM\"},{\"id\":\"KTN_QBuDplo\"}]},{\"id\":\"2\",\"name\":\"K8s in the Cloud\",\"videos\":[{\"id\":\"c4nTKMU6fBU\"},{\"id\":\"p6xDCz00TxU\"}]},{\"id\":\"3\",\"name\":\"Storage and MessageBrokers\",\"videos\":[{\"id\":\"A_XAVFfFbmI\"},{\"id\":\"_lpDfMkxccc\"}]},{\"id\":\"4\",\"name\":\"Linux AI\",\"videos\":[{\"id\":\"EtJY6J-h8LQ\"},{\"id\":\"z6qr3y0E2D4\"}]}]"

```

Then run:

```redis
BGREWRITEAOF
```

Exit:

```bash
exit
```

---

## 📤 STEP 3: Copy the AOF out of the container

```bash
docker cp redis-playlist-tmp:/data/appendonly.aof ./appendonly.aof
```

Optional: stop & remove the temp container:

```bash
docker rm -f redis-playlist-tmp
```

---

## 🧱 STEP 4: Create the Dockerfile

Create a new directory like `playlistdb/`, and inside it:

### `Dockerfile`

```Dockerfile
FROM redis:6.0-alpine
COPY appendonly.aof /data/appendonly.aof
CMD ["redis-server", "--appendonly", "yes"]
```

Place your `appendonly.aof` in the same folder.

---

## 🏗️ STEP 5: Build the custom image

```bash
docker build -t stv707/playlistdb:v1 .
```

---
## 🧪 STEP 6: Test your new image

```bash
docker run -d --name playlist-test -p 6379:6379 stv707/playlistdb:v1
docker exec -it playlist-test redis-cli
GET playlists
```

You should get your JSON. ✅

---

## 📤 STEP7:  Push to Docker Hub

```bash
docker login
docker push stv707/playlistdb:v1
```

