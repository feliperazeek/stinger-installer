#!/bin/bash

# This super simple script followed the following documentation
# with some minor additions like adding hive-site.xml to Hive's conf dir and MySQL's JDBC driver to Hive's lib dir:
# http://public-repo-1.hortonworks.com/HDP-LABS/Projects/Stinger/StingerTechnicalPreviewInstall.pdf

# Make sure HADOOP_HOME is set
: ${HADOOP_HOME?"Need to set HADOOP_HOME"}

# Clear out this bitch
clear

# Cleanup HDFS paths that will be created during this installation
hadoop fs -rm -r /apps/tez
hadoop fs -rm -r /user/hive/hive-exec-0.13.0-SNAPSHOT.jar

# Remove directories which we'll use to install this thing
sudo rm -rf /opt/apache-hive*
sudo rm -rf /opt/tez*

# Make sure /opt is created
sudo mkdir /opt

# Download Stinger
wget https://github.com/cartershanklin/StingerQuickstart/blob/master/Stinger-Preview-Quickstart.tgz?raw=true
tar -xzf Stinger-Preview-Quickstart.tgz*
cd Stinger-Preview-Quickstart

# Download Tez
wget http://public-repo-1.hortonworks.com/HDP-2.1.0.0/repos/centos6/tars/tez-0.2.0.2.1.0.0-92.tar.gz
sudo tar -C /opt -xzf tez-0.2.0.2.1.0.0-92.tar.gz
sudo chown -R $USER /opt/tez*

# Create the HDFS locations used by Tez
hadoop fs -mkdir -p /apps/tez
hadoop fs -chmod 755 /apps/tez

# Copy Tez to HDFS
hadoop fs -copyFromLocal /opt/tez-0.2.0.2.1.0.0-92/* /apps/tez/

# Copy the tez configuration to the conf directory of Hadoop
cp configs/tez-site.xml.sandbox $HADOOP_HOME/etc/hadoop/tez-site.xml

# Download Hive
wget http://public-repo-1.hortonworks.com/HDP-2.1.0.0/repos/centos6/tars/apache-hive-0.13.0.2.1.0.0-92-bin.tar.gz

# Copy Hive to /opt
sudo tar -C /opt -xzf apache-hive-0.13.0.2.1.0.0-92-bin.tar.gz
sudo chown -R $USER /opt/apache-hive*

# Copy the hive configuration enabling Tez and connecting to MySQL for the datastore
cd ..
cp hive-site.xml /opt/apache-hive-0.13.0.2.1.0.0-92-bin/conf

# Create Hive directories on HDFS
hadoop fs -mkdir -p /user/hive
hadoop fs -chmod 755 /user/hive

# Copy Hive jar to HDFS
hadoop fs -put /opt/apache-hive-0.13.0.2.1.0.0-92-bin/lib/hive-exec-*.jar /user/hive/hive-exec-0.13.0-SNAPSHOT.jar

# Download MySQL JDBC driver and copy to Hive's classpath
wget http://mysql.mirror.facebook.net/Connector-J/mysql-connector-java-5.1.28.zip
unzip mysql-connector-java-5.1.28.zip
cp mysql-connector-java-5.1.28/mysql-connector-java-5.1.28-bin.jar /opt/apache-hive-0.13.0.2.1.0.0-92-bin/lib/

# Cleanup this bitch
clear

# Tell this fool to add the Hive stuff to their env config
echo "[ACTION REQUIRED] Add the following to $HOME/.bash_profile:"
echo "-----------------------------------------------------------"
cat bash_profile
echo "-----------------------------------------------------------"
echo ""
echo ""

# Cleanup files used during installation
rm -rf *.gz
rm -rf *.tgz*
rm -rf *.zip
rm -rf Stinger*
rm -rf mysql*
rm -rf apache*
