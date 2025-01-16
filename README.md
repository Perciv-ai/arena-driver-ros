# novatel-driver-ros
This repository contains a containerized ROS1 driver for the Arena camera.

## Prerequisites
Instructions for installing Docker can be found [here](https://docs.docker.com/engine/install/debian/).
Also ensure you download their SDK from [here](https://thinklucid.com/downloads-hub/). It is required for the driver but too large to have on Github.

## Building Docker container
To create the Docker image, run:
```bash
make build
```

## Running Docker container
To run the Docker image, run:
```bash
make run
```

## Documentation
For documentation on the driver, see their offical [page](https://support.thinklucid.com/using-ros-for-linux/).