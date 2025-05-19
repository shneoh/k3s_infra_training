# Let’s build a **custom Redis image** called `stv707/videosdb:v1`, based on `redis:6.0-alpine`, with a valid, Redis-generated `appendonly.aof` preloaded.


Here’s the full step-by-step to:

1. 🔧 Start Redis (`redis:6.0-alpine`) with AOF enabled
2. 🛠️ Insert data manually
3. 💾 Generate `.aof` file
4. 📂 Copy `.aof` file out from the container (optional)

---

## 🐳 Step 1: Start Redis in Docker with AOF enabled

```bash
docker run -d \
  --name redis-aof \
  -p 6379:6379 \
  redis:6.0-alpine \
  redis-server --appendonly yes
```

* This enables AOF persistence (`appendonly.aof` gets written to `/data`)
* `-p 6379:6379` so you can access Redis from your host

---

## 🧨 Step 2: Access the Redis container

```bash
docker exec -it redis-aof sh
```

Then launch Redis CLI:

```sh
redis-cli
```

Now you're inside Redis shell.

---

## 📝 Step 3: Insert Your JSON Data

```redis
SET EtJY6J-h8LQ '{"id": "EtJY6J-h8LQ", "title": "Linux AI Redhat", "imageurl": "https://i.ibb.co/WpVJjyLN/redhat-ai.jpg", "url": "https://youtu.be/EtJY6J-h8LQ", "description": ""}'
SET z6qr3y0E2D4 '{"id": "z6qr3y0E2D4", "title": "Linux AI Ubuntu", "imageurl": "https://i.ibb.co/B53tF9TL/ubuntu-ai.jpg", "url": "https://youtu.be/z6qr3y0E2D4", "description": ""}'
SET A_XAVFfFbmI '{"id": "A_XAVFfFbmI", "title": "Redis on Kubernetes", "imageurl": "https://i.ibb.co/s9XGvN55/redis-k8s.jpg", "url": "https://youtu.be/A_XAVFfFbmI", "description": ""}'
SET _lpDfMkxccc '{"id": "_lpDfMkxccc", "title": "RabbitMQ on Kubernetes", "imageurl": "https://i.ytimg.com/vi/_lpDfMkxccc/sddefault.jpg", "url": "https://youtu.be/_lpDfMkxccc", "description": ""}'
SET FmLna7tHDRc '{"id": "FmLna7tHDRc", "title": "K3s", "imageurl": "https://i.ibb.co/G1DNBGk/K3s.jpg", "url": "https://youtu.be/FmLna7tHDRc", "description": ""}'
SET nRVBNkcr4eM '{"id": "nRVBNkcr4eM", "title": "Rancher", "imageurl": "https://i.ibb.co/hRQ1Vh6B/rancher-platform.jpg", "url": "https://youtu.be/nRVBNkcr4eM", "description": ""}'
SET KTN_QBuDplo '{"id": "KTN_QBuDplo", "title": "OpenShift", "imageurl": "https://i.ibb.co/zh2TpJQG/Red-Hat-Open-Shift.jpg", "url": "https://youtu.be/KTN_QBuDplo", "description": ""}'
SET c4nTKMU6fBU '{"id": "c4nTKMU6fBU", "title": "Kubernetes on Azure", "imageurl": "https://i.ibb.co/LdHDgWvy/Microsoft-Azure.jpg", "url": "https://youtu.be/c4nTKMU6fBU", "description": ""}'
SET p6xDCz00TxU '{"id": "p6xDCz00TxU", "title": "Kubernetes on AWS", "imageurl": "https://i.ibb.co/QSWgQKt/aws.jpg", "url": "https://youtu.be/p6xDCz00TxU", "description": ""}'

...
```

---

## 💾 Step 4: Trigger AOF Write (optional)

After inserting your data, you can force Redis to rewrite the AOF:

```redis
BGREWRITEAOF
```

---

## 📦 Step 5: Exit and Copy the AOF File

Exit Redis and back in shell:

```bash
exit
```

Now copy the file to your host:

```bash
docker cp redis-aof:/data/appendonly.aof ./appendonly.aof
```

You now have a **valid Redis-generated AOF file**. 🧨

---

## 🧱 STEP 6: Create the Dockerfile

Create a new directory like `data/`, and inside it:

### `Dockerfile`

```Dockerfile
FROM redis:6.0-alpine
COPY appendonly.aof /data/appendonly.aof
CMD ["redis-server", "--appendonly", "yes"]
```

Place your `appendonly.aof` in the same folder.

---

## 🏗️ STEP 7: Build the custom image

```bash
docker build -t stv707/videosdb:v1 .
```

---

## 🧪 STEP 8: Test your new image

```bash
docker run -d --name videosdb-test -p 6379:6379 stv707/videosdb:v1
docker exec -it videosdb-test redis-cli
KEYS "*"
```

You should get your JSON. ✅

---

## 📤 STEP 9:  Push to Docker Hub

```bash
docker login
docker push stv707/videosdb:v1
```
