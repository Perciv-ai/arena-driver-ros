# Step 1: Use the official ROS Noetic image as the base
ARG ROS_DISTRO=noetic

FROM osrf/ros:${ROS_DISTRO}-desktop-full
ENV DEBIAN_FRONTEND=noninteractive

# Step 2: Install system dependencies required for the build
RUN apt-get update && apt-get install -y --no-install-recommends\
    git \
    build-essential \
    python3-catkin-tools \
    python3-pip \
    python3-rosdep \
    python3-rospkg \
    sudo \
    lsb-release \
    curl \
    cmake \
    git \
    wget \
    vim \
    nano
# Step 3: Add the ROS Noetic package repository
RUN curl -sSL "http://packages.ros.org/ros.key" | apt-key add - \
    && echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -c | awk '{print $2}'` main" > /etc/apt/sources.list.d/ros2.list

ARG ROS=ros-${ROS_DISTRO}
# Step 4: Install ROS dependencies (ensure the list is updated)
RUN apt-get update && apt-get install -y \
    ${ROS}-rosdoc-lite 
    # ${ROS}-tf2-geometry-msgs \
    # ${ROS}-gps-common \
    # ${ROS}-nav-msgs \
    # ${ROS}-nmea-msgs 
# Step 5: Set up the environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO=${ROS_DISTRO}

# Step 6: Install rosdep (if not installed) and update rosdep
RUN rosdep init || true && rosdep update

COPY ./ArenaSDK_v0.1.91_Linux_x64.tar.gz /
RUN tar -xvf /ArenaSDK_v0.1.91_Linux_x64.tar.gz -C ~
RUN cd ~/ArenaSDK_Linux_x64/ && sh Arena_SDK_Linux_x64.conf
RUN echo "export ARENA_ROOT=~/ArenaSDK_Linux_x64" >> ~/.bashrc
RUN . ~/.bashrc


# Step 7: Copy the 'src' directory from your local machine into the container
RUN mkdir -p /ws/catkin_ws
WORKDIR /ws/catkin_ws
COPY ./catkin_ws /ws/catkin_ws
RUN cp /opt/ros/noetic/include/sensor_msgs/image_encodings.h /opt/ros/noetic/include/sensor_msgs/image_encodings.h.bak
RUN cp inc/image_encodings.h /opt/ros/noetic/include/sensor_msgs/image_encodings.h
RUN rosdep install --from-paths src --ignore-src -r -y
RUN . /opt/ros/noetic/setup.sh && catkin build -j1 -l1


RUN /bin/bash -c '. /opt/ros/noetic/setup.bash'

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /ws/catkin_ws/devel/setup.bash" >> ~/.bashrc

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Step 12: Set up the entry point to run the container interactively with ROS
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Define the entry point for the container
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]