#!/bin/bash

set -e

OBJSLAMPP_PREFIX=$HOME/ros_objslampp/src/objslampp
ROSOBJSLAMPP_PREFIX=$HOME/ros_objslampp

if [ ! -d $OBJSLAMPP_PREFIX ]; then
  echo "Please install objslampp to $OBJSLAMPP_PREFIX"
  exit 1
fi

if [ ! -e $OBJSLAMPP_PREFIX/.anaconda3/bin/activate ]; then
  echo "Please run 'make install' in objslampp"
  exit 1
fi

unset PYTHONPATH
unset CMAKE_PREFIX_PATH

source $OBJSLAMPP_PREFIX/.anaconda3/bin/activate
source /opt/ros/kinetic/setup.bash

set -x

pip install catkin_pkg
pip install rospkg
pip install empy
pip install netifaces

mkdir -p $ROSOBJSLAMPP_PREFIX/src
cd $ROSOBJSLAMPP_PREFIX
catkin init

if [ ! -e $ROSOBJSLAMPP_PREFIX/src/.rosinstall ]; then
  ln -s $ROSOBJSLAMPP_PREFIX/src/objslampp/ros/rosinstall $ROSOBJSLAMPP_PREFIX/src/.rosinstall
  (cd $ROSOBJSLAMPP_PREFIX/src && wstool up)
fi

if [ ! -e $ROSOBJSLAMPP_PREFIX/.autoenv.zsh ]; then
  cp $OBJSLAMPP_PREFIX/ros/template.autoenv.zsh $ROSOBJSLAMPP_PREFIX/.autoenv.zsh
fi
if [ ! -e $ROSOBJSLAMPP_PREFIX/.autoenv_leave.zsh ]; then
  cp $OBJSLAMPP_PREFIX/ros/template.autoenv_leave.zsh $ROSOBJSLAMPP_PREFIX/.autoenv_leave.zsh
fi

catkin config --merge-devel \
              -DPYTHON_EXECUTABLE=$OBJSLAMPP_PREFIX/.anaconda3/bin/python \
              -DPYTHON_INCLUDE_DIR=$OBJSLAMPP_PREFIX/.anaconda3/include/python3.7m \
              -DPYTHON_LIBRARY=$OBJSLAMPP_PREFIX/.anaconda3/lib/libpython3.7m.so \
              --cmake-args -DCMAKE_BUILD_TYPE=Release -DOCTOMAP_OMP=1
catkin config --blacklist \
  checkerboard_detector \
  jsk_network_tools \
  jsk_tools \
  jsk_recognition_msgs \
  imagesift \
  image_view2 \
  jsk_perception \
  jsk_pcl_ros \
  jsk_pcl_ros_utils \
  rosbag \
  rosbag_storage \
  franka_control \
  franka_visualization
mkdir -p $ROSOBJSLAMPP_PREFIX/devel/lib/python3/dist-packages
ln -fs $OBJSLAMPP_PREFIX/.anaconda3/lib/python3.7/site-packages/cv2 $ROSOBJSLAMPP_PREFIX/devel/lib/python3/dist-packages

catkin build cv_bridge

set +x
source $OBJSLAMPP_PREFIX/.anaconda3/bin/activate
source /opt/ros/kinetic/setup.bash
source $ROSOBJSLAMPP_PREFIX/devel/setup.bash
set -x

python -c 'import cv2'
python -c 'from cv_bridge.boost.cv_bridge_boost import getCvType'

catkin build ros_objslampp_ycb_video