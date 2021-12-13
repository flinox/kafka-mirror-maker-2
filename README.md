# Mirror Maker 2 - MM2
An implementation of Apache Kafka Mirror Maker 2 ( MM2 ) to replicate kafka topics between clusters kafka ( Inclusive Azure Event Hub ).
Kafka version 3.0.0 and Scala 2.13

### Settings the credentials of source and target

Use the template **[/properties/template_access.properties](/properties/template_access.properties)** para gerar um arquivo **[/properties/access.properties](/properties/access.properties)** com as informações de acesso ao Kafka e ao Azure Event Hub.

Este arquivo será usado pelo MM2.

### Setting the MM2
You must settings the MM2 and enable the topics and the flow witch you want to replicate:

[/config/mm2-config.properties](/config/mm2-config.properties)

Label your environments:
```properties
clusters=source,target
```

Use this lable as a prefix to override settings of the environment:
```properties
source.bootstrap.servers=${file:/properties/access.properties:SRC_BROKERS}
target.bootstrap.servers=${file:/properties/access.properties:TGT_BROKERS}
```

You just need to setup the topics and enable the mirroring:
```properties
source->target.enabled=true
source->target.topics=topic1,topic2
```


### Running the MM2

Below the command to run it:

```shell
connect-mirror-maker.sh ./config/mm2-config.properties
```

The docker image I created, runs the command above automatically, you just need to build the image and run it, example:

Build:
```shell
docker build -t flinox/mm2-replicator:latest .
```

Run:
```shell
docker run --rm -it --hostname mm2-replicator --name mm2-replicator \
--mount type=bind,source="$(pwd)"/config,target=/app/replicator/config/ \
--mount type=bind,source="$(pwd)"/properties,target=/properties/ \
--security-opt label=disable \
flinox/mm2-replicator:latest 
```

Or you can set the script [docker-run.sh](docker-run.sh):

```shell
./docker-run.sh
```

- [Documentation](https://kafka.apache.org/documentation/#basic_ops_mirror_maker)
- [Download MM2](https://www.apache.org/dyn/closer.cgi?path=/kafka/3.0.0/kafka_2.13-3.0.0.tgz)

### Control topics

I noticed some control topics used by MM2:

Source:
```
mm2-offsets-syncs.[target_label].internal
mm2-configs
mm2-offsets
mm2-status
```


Destino:
```
[source_label].checkpoints.internal
[source_label].heartbeats
heartbeats
mm2-configs.[source_label].internal
mm2-offsets.[source_label].internal
mm2-status.[source_label].internal
```

In addition to the main topic of messages that is created in the target with the prefix defined in the settings:
```
[source_label].topic1
[source_label].topic2
```


### `Other informations to help`

> Pre-reqs for Azure Event Hub as Target

The user must have permissions:

**Manage, Send and Listen** 

The permission **Manage** is nedded to create the control topics on the target.

The Event Hub must be at least in a tier STANDARD, to use kafka integration features:

More information:
[https://github.com/Azure/azure-event-hubs-for-kafka](https://github.com/Azure/azure-event-hubs-for-kafka)



> Concepts between Kafka x Azure Event Hub

| Kafka | Event Hub |
| ----- | ----- |
|Cluster | Namespace |
|Topic | Event Hub |
| Partition | Partition |
| Consumer Group | Consumer Group |
| Offset | Offset |


> To test connectivity

```
openssl s_client -connect krotondevpoc.servicebus.windows.net:9093
```

### `Mirror Maker 2, components`

#### MirrorSourceConnector

![MirrorSourceConnector](/images/getting-up-to-speed-with-mirrormaker-2-mickael-maison-ibm-ryanne-dolan-kafka-summit-2020-9-1024.jpg)


#### MirrorCheckpointConnector
![MirrorCheckpointConnector](/images/getting-up-to-speed-with-mirrormaker-2-mickael-maison-ibm-ryanne-dolan-kafka-summit-2020-10-1024.jpg)


#### MirrorHeartbeatConnector
![MirrorHeartbeatConnector](/images/getting-up-to-speed-with-mirrormaker-2-mickael-maison-ibm-ryanne-dolan-kafka-summit-2020-11-1024.jpg)


#### Dedicated 
![Dedicated](/images/getting-up-to-speed-with-mirrormaker-2-mickael-maison-ibm-ryanne-dolan-kafka-summit-2020-13-1024.jpg)


#### Reusa connect cluster
![Connect](/images/getting-up-to-speed-with-mirrormaker-2-mickael-maison-ibm-ryanne-dolan-kafka-summit-2020-15-1024.jpg)


## `References`
https://docs.microsoft.com/pt-br/azure/event-hubs/apache-kafka-developer-guide

https://github.com/Azure/azure-event-hubs-for-kafka

https://docs.microsoft.com/en-us/azure/event-hubs/apache-kafka-troubleshooting-guide

https://cwiki.apache.org/confluence/display/KAFKA/KIP-382%3A+MirrorMaker+2.0

https://docs.confluent.io/5.5.4/connect/kafka-connect-azure-event-hubs/index.html

https://docs.confluent.io/5.5.4/connect/kafka-connect-azure-event-hubs/azure_event_hubs_source_connector_config.html#event-hubs-source-connector-config

https://hub.docker.com/r/confluentinc/cp-enterprise-replicator

https://kafka.apache.org/documentation/#basic_ops_mirror_maker

https://www.confluent.io/resources/kafka-summit-2020/getting-up-to-speed-with-mirrormaker-2/

https://docs.microsoft.com/pt-br/azure/event-hubs/event-hubs-kafka-mirror-maker-tutorial