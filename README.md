# Repo structure
```
.
├── README.md
├── downloads
│   ├── apache-hive-2.3.2-bin.tar.gz
│   ├── apache-nutch-1.18-bin.tar.gz
│   ├── geckodriver-v0.29.1-linux64.tar.gz
│   ├── hadoop-2.7.1.tar.gz
│   ├── hbase-1.2.6-bin.tar.gz
│   ├── scala-2.12.4.tgz
│   ├── solr-8.5.1.tgz
│   └── spark-2.2.1-bin-hadoop2.7.tgz
├── key_deploy
├── key_root
└── src
    ├── LICENSE
    ├── ansible.cfg
    ├── hbase.yml
    ├── hive.yml
    ├── hosts
    ├── master.yml
    ├── nutch.yml
    ├── roles
    ├── spark.yml
    ├── vars
    └── workers.yml
```
## Description
1. downloads: All binaries required for installation
IMPORTANT: Read GIT LFS note in the following section!
2. key_deploy: Replace it with your own SSH key (the key you have to SSH to the remote servers)
3. src: Ansible playbooks to install the whole Apache Datawarehouse platform

# GIT-LFS
1. Install git-lfs
If you're using GitBash (Windows), open GitBash windows, type below command:
```
git lfs install
```
If you're using Git for Linux (Ubuntu/Debian), open a terminal, type below commands:
```
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
git lfs install
```
2. git-lfs pull
In your terminal (or GitBash window), type below commands
```
cd downloads
git lfs fetch
git lfs pull
```
3. Why you have to do that?
The tarballs in the download folder are huge. They were uploaded onto Git Large File System on Github!
In order to save your bandwidth, they should be available offline first in download folder.

# Software to be installed
- OS: Centos 7.x
- JDK:Openjdk-1.8
- Hadoop: 3.0.0
- Hive: 2.3.2
- Hbase: 1.2.6
- Spark: 2.2.1
- Scala: 2.12.4
- Solr: 8.5.1
- Nutch: 1.18
- Geckodriver: 0.29.1
- Selenium-plugin

# Hosts
See host defined in hosts/host

# How to install
## Install ansible. See instruction [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
## Check out this source code
```
git clone https://github.com/ngphban/apache-dwh.git
```
## Go over src folder: 
```
cd src/
```
## Replace key_deploy with your own SSH key
## Follow below installation commands step-by-step

## Install Hadoop
1. Download Hadoop
2. Update vars/var_basic.yml {{ download_path }}
```
download_path: "/home/vagrant/downloads" # your local path
hadoop_version: "3.0.0" # your hadoop version
hadoop_path: "/home/hadoop" # default in user "hadoop" home
hadoop_config_path: "/home/hadoop/hadoop-{{hadoop_version}}/etc/hadoop"
hadoop_tmp: "/home/hadoop/tmp"
hadoop_dfs_name: "/home/hadoop/dfs/name"
hadoop_dfs_data: "/home/hadoop/dfs/data"

```
3. Use ansible template to dynamically generate configuration files. If you need to add configuration, you can directly update the relevant properties array in vars/var_xxx.yml. The default configuration of Hadoop is:

```
# hadoop configration
hdfs_port: 9000
core_site_properties:
  - {
      "name":"fs.defaultFS",
      "value":"hdfs://{{ master_ip }}:{{ hdfs_port }}"
  }
  - {
      "name":"hadoop.tmp.dir",
      "value":"file:{{ hadoop_tmp }}"
  }
  - {
    "name":"io.file.buffer.size",
    "value":"131072"
  }

dfs_namenode_httpport: 9001
hdfs_site_properties:
  - {
      "name":"dfs.namenode.secondary.http-address",
      "value":"{{ master_hostname }}:{{ dfs_namenode_httpport }}"
  }
  - {
      "name":"dfs.namenode.name.dir",
      "value":"file:{{ hadoop_dfs_name }}"
  }
  - {
      "name":"dfs.namenode.data.dir",
      "value":"file:{{ hadoop_dfs_data }}"
  }
  - {
      "name":"dfs.replication",
      "value":"{{ groups['workers']|length }}"
  }
  - {
    "name":"dfs.webhdfs.enabled",
    "value":"true"
  }

mapred_site_properties:
 - {
   "name": "mapreduce.framework.name",
   "value": "yarn"
 }
 - {
   "name": "mapreduce.admin.user.env",
   "value": "HADOOP_MAPRED_HOME=$HADOOP_COMMON_HOME"
 }
 - {
   "name":"yarn.app.mapreduce.am.env",
   "value":"HADOOP_MAPRED_HOME=$HADOOP_COMMON_HOME"
 }

yarn_resourcemanager_port: 8040
yarn_resourcemanager_scheduler_port: 8030
yarn_resourcemanager_webapp_port: 8088
yarn_resourcemanager_tracker_port: 8025
yarn_resourcemanager_admin_port: 8141

yarn_site_properties:
  - {
    "name":"yarn.resourcemanager.address",
    "value":"{{ master_hostname }}:{{ yarn_resourcemanager_port }}"
  }
  - {
    "name":"yarn.resourcemanager.scheduler.address",
    "value":"{{ master_hostname }}:{{ yarn_resourcemanager_scheduler_port }}"
  }
  - {
    "name":"yarn.resourcemanager.webapp.address",
    "value":"{{ master_hostname }}:{{ yarn_resourcemanager_webapp_port }}"
  }
  - {
    "name": "yarn.resourcemanager.resource-tracker.address",
    "value": "{{ master_hostname }}:{{ yarn_resourcemanager_tracker_port }}"
  }
  - {
    "name": "yarn.resourcemanager.admin.address",
    "value": "{{ master_hostname }}:{{ yarn_resourcemanager_admin_port }}"
  }
  - {
    "name": "yarn.nodemanager.aux-services",
    "value": "mapreduce_shuffle"
  }
  - {
    "name": "yarn.nodemanager.aux-services.mapreduce.shuffle.class",
    "value": "org.apache.hadoop.mapred.ShuffleHandler"
  }
```


---
**Note**
```
hdfs_site_properties:
  - {
      "name":"dfs.namenode.secondary.http-address",
      "value":"{{ master_hostname }}:{{ dfs_namenode_httpport }}"
  }
  - {
      "name":"dfs.namenode.name.dir",
      "value":"file:{{ hadoop_dfs_name }}"
  }
  - {
      "name":"dfs.namenode.data.dir",
      "value":"file:{{ hadoop_dfs_data }}"
  }
  - {
      "name":"dfs.replication",
      "value":"{{ groups['workers']|length }}"  # this is  the group "workers" you define in hosts/host
  }
  - {
    "name":"dfs.webhdfs.enabled",
    "value":"true"
  }
```

### Install Master
1. master.yml
```
- hosts: master
  become: yes
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
  vars:
     add_user: true           # add user "hadoop"
     generate_key: true       # generate the ssh key
     open_firewall: true      # for CentOS 7.x is firewalld
     disable_firewall: false  # disable firewalld
     install_hadoop: true     # install hadoop,if you just want to update the configuration, set to false
     config_hadoop: true      # Update configuration
  roles:
    - user                    # add user and generate the ssh key
    - fetch_public_key        # get the key and put it in your localhost
    - authorized              # push the ssh key to the remote server
    - java                    # install jdk
    - hadoop                  # install hadoop

```
2. Command

```
ansible-playbook -i hosts/host master.yml
```

### Install Workers
1.  workers.yml
```
# Add Master Public Key   # get master ssh public key
- hosts: master
  become: yes
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_workers.yml
  roles:
    - fetch_public_key

- hosts: workers
  become: yes
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_workers.yml
  vars:
    add_user: true
    generate_key: false # workers just use master ssh public key
    open_firewall: false
    disable_firewall: true  # disable firewall on workers
    install_hadoop: true
    config_hadoop: true
  roles:
    - user
    - authorized
    - java
    - hadoop

```
Command:

```
master_ip:  your hadoop master ip
master_hostname: your hadoop master hostname

above two variables must be same like your real hadoop master

ansible-playbook -i hosts/host workers.yml -e "master_ip=45.32.119.181 master_hostname=hadoop-master"

```
### Post HDFS install
1. On Master node:
```
Command
```
sudo su - hadoop
cd $HADOOP_HOME
hdfs namenode -format # RUN ONLY ONCE!!
start-dfs.sh
jps # CHECK ON MASTER AND WORKERS NODES
```
Check URL: http://hadoop-master:50070/
```

### Install hive
1. **Create a database and give the correct permissions**
2.  vars/var_hive.yml
```
---

# hive basic vars
download_path: "/home/vagrant/downloads"                               # your download path
hive_version: "2.3.2"                                                  # your hive version
hive_path: "/home/hadoop"
hive_config_path: "/home/hadoop/apache-hive-{{hive_version}}-bin/conf"
hive_tmp: "/home/hadoop/hive/tmp"                                      # your hive tmp path

hive_create_path:
  - "{{ hive_tmp }}"

hive_warehouse: "/user/hive/warehouse"                                  # your hdfs path
hive_scratchdir: "/user/hive/tmp"
hive_querylog_location: "/user/hive/log"

hive_hdfs_path:
  - "{{ hive_warehouse }}"
  - "{{ hive_scratchdir }}"
  - "{{ hive_querylog_location }}"

hive_logging_operation_log_location: "{{ hive_tmp }}/{{ user }}/operation_logs"

# database
db_type: "postgres"                                              # use your db_type, default is postgres
hive_connection_driver_name: "org.postgresql.Driver"
hive_connection_host: "192.168.0.2"
hive_connection_port: "5432"
hive_connection_dbname: "hive"
hive_connection_user_name: "hive_user"
hive_connection_password: "nfsetso12fdds9s"
hive_connection_url: "jdbc:postgresql://{{ hive_connection_host }}:{{ hive_connection_port }}/{{hive_connection_dbname}}?ssl=false"
# hive configration                                             # your hive site properties
hive_site_properties:
  - {
      "name":"hive.metastore.warehouse.dir",
      "value":"hdfs://{{ master_hostname }}:{{ hdfs_port }}{{ hive_warehouse }}"
  }
  - {
      "name":"hive.exec.scratchdir",
      "value":"{{ hive_scratchdir }}"
  }
  - {
      "name":"hive.querylog.location",
      "value":"{{ hive_querylog_location }}/hadoop"
  }
  - {
      "name":"javax.jdo.option.ConnectionURL",
      "value":"{{ hive_connection_url }}"
  }
  - {
    "name":"javax.jdo.option.ConnectionDriverName",
    "value":"{{ hive_connection_driver_name }}"
  }
  - {
    "name":"javax.jdo.option.ConnectionUserName",
    "value":"{{ hive_connection_user_name }}"
  }
  - {
    "name":"javax.jdo.option.ConnectionPassword",
    "value":"{{ hive_connection_password }}"
  }
  - {
    "name":"hive.server2.logging.operation.log.location",
    "value":"{{ hive_logging_operation_log_location }}"
  }

hive_server_port: 10000                                    # hive port
hive_hwi_port: 9999
hive_metastore_port: 9083

firewall_ports:
  - "{{ hive_server_port }}"
  - "{{ hive_hwi_port }}"
  - "{{ hive_metastore_port }}"
```

3.  hive.yml

```
- hosts: hive                   # in hosts/host
  become: yes
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
   - vars/var_hive.yml            # var_hive.yml
  vars:
     open_firewall: true           
     install_hive: true           
     config_hive: true
     init_hive: true               # init hive database after install and config
  roles:
    - hive

```
4. Command

```
ansible-playbook -i hosts/host hive.yml

```

5. Hive post install
```
On Master node:
sudo su - hadoop
cd $HIVE_HOME/bin
hive
```
Test creating query:
CREATE TABLE demo (id int, name string);
SHOW TABLES;
DROP TABLE demo;

### Hbase

1.  vars/var_hbase.yml

```
---
# hbase basic vars
download_path: "/home/vagrant/downloads"    # your local download path
hbase_version: "1.2.6"                    # hbase version
hbase_path: "/home/hadoop"                # install dir
hbase_config_path: "/home/hadoop/hbase-{{hbase_version}}/conf"

hbase_tmp: "{{ hbase_path }}/hbase/tmp"
hbase_zookeeper_config_path: "{{ hbase_path }}/hbase/zookeeper"
hbase_log_path: "{{ hbase_path }}/hbase/logs"

hbase_create_path:
  - "{{ hbase_tmp }}"
  - "{{ hbase_zookeeper_config_path }}"
  - "{{ hbase_log_path }}"


# hbase configration
hbase_hdfs_path: "/hbase"
zk_hosts: "zookeeper"                  #zookeeper group name in hosts/host
zk_client_port: 12181                  #zookeeper client port

hbase_master_port: 60000               #hbase port
hbase_master_info_port: 60010
hbase_regionserver_port: 60020
hbase_regionserver_info_port: 60030
hbase_rest_port: 8060


hbase_site_properties:                 #property
  - {
      "name":"hbase.master",
      "value":"{{ hbase_master_port }}"
  }
  - {
      "name":"hbase.master.info.port",
      "value":"{{ hbase_master_info_port }}"
  }
  - {
      "name":"hbase.tmp.dir",
      "value":"{{ hbase_tmp }}"
  }
  - {
      "name":"hbase.rootdir",
      "value":"hdfs://{{ master_hostname }}:{{ hdfs_port }}{{ hbase_hdfs_path }}"
  }
  - {
      "name":"hbase.regionserver.port",
      "value":"{{ hbase_regionserver_port }}"
  }
  - {
      "name":"hbase.regionserver.info.port",
      "value":"{{ hbase_regionserver_info_port }}"
  }
  - {
      "name":"hbase.rest.port",
      "value":"{{ hbase_rest_port }}"
  }
  - {
      "name":"hbase.cluster.distributed",
      "value":"true"
  }
  - {
      "name":"hbase.zookeeper.quorum"
  }


firewall_ports:
  - "{{ hbase_master_port }}"
  - "{{ hbase_master_info_port }}"
  - "{{ hbase_regionserver_port }}"
  - "{{ hbase_regionserver_info_port }}"
  - "{{ hbase_rest_port }}"
 
```

2. Add zookeeper to hosts/host
```
[zookeeper]
172.16.251.70
172.16.251.71
172.16.251.72

```
3. zookeeper 
Install later

4.  hbase.yml

```
- hosts: hbase
  become: yes
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
   - vars/var_hbase.yml
  vars:
     open_firewall: true       # firewalld
     install_hbase: true       # install hbase
     config_hbase: true        # config hbase
  roles:
    - hbase
```
5. Command

```
ansible-playbook -i hosts/host  hbase.yml

```

### Install spark
1. Download scala-spark {{ download_path }}
2. vars/var_spark.yml

```
---
# spark basic vars
download_path: "/home/vagrant/downloads"    # your local download path
spark_package_name: "spark-2.2.1-bin-hadoop2.7" # spark package name
spark_version: "2.2.1"                    # spark version
spark_path: "/home/hadoop"                # install dir
spark_config_path: "/home/hadoop/spark-{{spark_version}}/conf"

spark_worker_path: "{{ spark_path }}/spark/worker"
spark_log_path: "{{ spark_path }}/spark/logs"

master_hostname: "{{ master_hostname }}"

spark_hdfs_path: "hdfs://{{ master_hostname }}:{{ hdfs_port }}/spark/history_log"

spark_create_path:
  - "{{ spark_worker_path }}"
  - "{{ spark_log_path }}"

#scala vars
scala_path: "{{ spark_path }}"
scala_version: "2.12.4"               # scala version


spark_master_port: 17077               #spark port
spark_history_ui_port: 17777
spark_web_port: 18080


spark_properties:                     #property
  - {
      "name":"spark.master",
      "value":"spark://{{ master_hostname }}:{{ spark_master_port }}"
  }
  - {
      "name":"spark.eventLog.dir",
      "value":"{{ spark_hdfs_path }}"
  }
  - {
      "name":"spark.eventLog.compress",
      "value":"true"
  }
  - {
      "name":"spark.history.updateInterval",
      "value":"5"
  }
  - {
      "name":"spark.history.ui.port",
      "value":"{{ spark_history_ui_port }}"
  }
  - {
      "name":"spark.history.fs.logDirectory ",
      "value":"{{ spark_hdfs_path }}"
  }

firewall_ports:
  - "{{ spark_master_port }}"
  - "{{ spark_history_ui_port }}"
  - "{{ spark_web_port }}"

```

3. Add spark to hosts/host

```
[spark]
172.16.251.70
172.16.251.71
172.16.251.72

```
4. spark.yml

```
- hosts: spark
  become: yes
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
   - vars/var_spark.yml
  vars:
     open_firewall: true        # firewalld
     install_spark: true        # install spark
     config_spark:  true        # config spark
     install_scala: true        # install scala
  roles:
    - spark

```
5. Command

```
master_hostname ： your master hostname
ansible-playbook -i hosts/host  spark.yml -e "master_hostname=hadoop-master"

### Install Nutch
```
1. Add variable in vars/var_nutch.yml
2. Add crawled URL in files/seed.txt
3. Add URL regext in files/url-filter.txt
6. Add crawling host in hosts/host
```
[nutch]
hadoop-worker01
```
5. Command
ansible-playbook -i hosts/host nutch.yml 

```

## License

GNU General Public License v3.0