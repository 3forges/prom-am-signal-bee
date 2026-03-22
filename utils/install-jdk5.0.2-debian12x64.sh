#!/bin/bash

curl -LO https://download.java.net/java/GA/jdk25.0.2/b1e0dfa218384cb9959bdcb897162d4e/10/GPL/openjdk-25.0.2_linux-x64_bin.tar.gz

tar xvf openjdk-25.0.2_linux-x64_bin.tar.gz

sudo mv jdk-25.0.2/ /opt/
sudo tee /etc/profile.d/jdk25.sh <<EOF
export JAVA_HOME=/opt/jdk-25.0.2
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
export JAVA_HOME=/opt/jdk-25.0.2
export PATH=$PATH:$JAVA_HOME/bin
source /etc/profile.d/jdk25.sh
java -version
# --- 
# openjdk version "25.0.2" 2022-07-19
# OpenJDK Runtime Environment (build 25.0.2+9-61)
# OpenJDK 64-Bit Server VM (build 25.0.2+9-61, mixed mode, sharing)
# 


exit 0 
curl -LO https://download.java.net/java/GA/jdk18.0.2/f6ad4b4450fd4d298113270ec84f30ee/9/GPL/openjdk-18.0.2_linux-x64_bin.tar.gz

tar xvf openjdk-18.0.2_linux-x64_bin.tar.gz

sudo mv jdk-18.0.2/ /opt/
sudo tee /etc/profile.d/jdk18.sh <<EOF
export JAVA_HOME=/opt/jdk-18.0.2
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
export JAVA_HOME=/opt/jdk-18.0.2
export PATH=$PATH:$JAVA_HOME/bin
source /etc/profile.d/jdk18.sh
java -version
# --- 
# openjdk version "18.0.2" 2022-07-19
# OpenJDK Runtime Environment (build 18.0.2+9-61)
# OpenJDK 64-Bit Server VM (build 18.0.2+9-61, mixed mode, sharing)
# 


exit 0 