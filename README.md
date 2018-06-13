# OverOps Base Docker Image

__*Please note, this is not an official OverOps repository or Docker image*__

This image serves as a base for other [OverOps](http://www.overops.com) related Docker images.  More info on this image can be found on [DockerHub](https://hub.docker.com/r/timveil/oo-docker-base/).


To build the image run the following command:
```bash
docker build --no-cache -t timveil/oo-docker-base:latest .
```

To publish the image run the following command:
```bash
docker push timveil/oo-docker-base:latest
```

To run the image execute the following command: 
```bash
docker run -it timveil/oo-docker-base
```