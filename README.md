# fsds-ros2-bridge

Docker setup for the ROS2 (Humble) bridge used with the [Formula Student
Driverless Simulator](https://github.com/FS-Driverless/Formula-Student-Driverless-Simulator)
(FSDS).

## What this is

The FSDS simulator binary runs **natively** on the host (Linux binary or
`FSDS.exe` on Windows) for direct GPU/Vulkan access. The ROS2 bridge that
talks to it, however, runs inside this **Ubuntu 22.04 + ROS2 Humble Docker
container**, so everyone on the team gets an identical, reproducible bridge
environment regardless of host OS or native ROS2 install.

Simulator and bridge communicate over TCP port `41451` (AirSim RPC),
regardless of the bridge running in a container.

## Contents

- `Dockerfile.fsds-ros2-humble` — builds the bridge image from
  `osrf/ros:humble-desktop`, with Ubuntu's `universe` repo enabled (needed
  for `clang-12`, which `AirSim/setup.sh` requires) plus the build tools,
  ROS2 packages, and `rosdep`/`colcon` tooling needed to build and run
  `fsds_ros2_bridge`.
- `run_fsds_ros2_bridge.sh` — starts the container with `--network=host`
  (so `localhost:41451` reaches the simulator on the host) and bind-mounts
  `~/Formula-Student-Driverless-Simulator` into the container, plus X11
  forwarding for optional `rviz2` use.

## Prerequisites

- `~/Formula-Student-Driverless-Simulator` cloned (with submodules) directly
  under your home directory — several paths are hardcoded to this location.
- The FSDS simulator binary unpacked and runnable natively (e.g. under
  `~/fsds-sim`).
- Docker installed (Docker Engine on Linux, Docker Desktop w/ WSL2 on
  Windows).

## Usage

```bash
# 1. Build the image (once, or after Dockerfile changes)
docker build -t fsds-ros2-humble -f Dockerfile.fsds-ros2-humble .

# 2. Start the simulator natively (separate terminal)
cd ~/fsds-sim && ./FSDS.sh -windowed -ResX=1280 -ResY=720

# 3. Start the bridge container
./run_fsds_ros2_bridge.sh

# 4. Inside the container: build the workspace (first time only, or after
#    a git pull/rebase touching AirSim/ or ros2/) and launch the bridge
cd /root/Formula-Student-Driverless-Simulator/AirSim && ./setup.sh
cd ../ros2 && rosdep install --from-paths src --ignore-src -r -y
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

source /opt/ros/humble/setup.bash
source /root/Formula-Student-Driverless-Simulator/ros2/install/setup.bash
ros2 launch fsds_ros2_bridge fsds_ros2_bridge.launch.py
```

On Windows (Docker Desktop), `--network=host` doesn't reach the Windows
host the same way — see the full runbook for the `host.docker.internal`
workaround.

## Full runbook

For the complete setup (Ubuntu + Windows hosts, verifying the connection,
rviz2, troubleshooting): see the team runbook,
`runbook-fsds-simulator-en.md`.
