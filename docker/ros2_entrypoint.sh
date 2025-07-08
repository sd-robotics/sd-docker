#!/bin/bash
alias cb='CURRENT_DIR=\`pwd\` && cd ~/colcon_ws/ && colcon build --symlink-install && source ~/.bashrc && cd \${CURRENT_DIR}'

source /opt/ros/humble/setup.bash
source ~/colcon_ws/install/setup.bash
export RMW_IMPLEMENTATION="rmw_cyclonedds_cpp"
export ROS_LOCALHOST_ONLY=1
export ROS_DOMAIN_ID=10

exec "$@"
