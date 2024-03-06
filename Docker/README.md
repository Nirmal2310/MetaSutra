### Instructions for Installing the Docker container of MetaShiny

#### Step 1: Installing the base container that MetaShiny Docker Container will use
```bash
docker build -t base:latest base
```
- Please Note that if you are working behind a proxy, edit lines 10,37 and 39 in the base Dockerfile specifying the proxy address. Also, if you are not working behind a proxy, comment on the same lines in the base Dockerfile.

#### Step 2: Installing the Docker container of MetaShiny
```bash
docker build -t metashiny:latest .
```
- Again, if you are working behind a proxy, you can edit lines 13 and 15 in the Dockerfile; otherwise, comment the same lines.
- The installation will download some databases required by the tools in the pipeline. So, please ensure you have enough space (~90GB) for the docker root directory. If you want to change the docker root directory, you can follow the instructions provided in this [blog.](https://www.ibm.com/docs/en/z-logdata-analytics/5.1.0?topic=software-relocating-docker-root-directory)
- The installation might take a long time, so try to launch the installation inside a screen.
