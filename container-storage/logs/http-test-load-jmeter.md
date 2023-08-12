```
# To install jmeter
# Note: Avoid using 'apt' to prevent installing an outdated version (2.13.20180731).
# Refresh packages metadata
sudo apt-get update
# Install Java 8 (a pre-requisite for JMeter)
sudo apt-get install openjdk-8-jre-headless
# Download JMeter 5.6.2 (Replace with the latest version/URL if needed)
cd /tmp
wget -c https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.2.tgz
# Unpack JMeter
tar -xf apache-jmeter-5.6.2.tgz

# Run a sample test
apache-jmeter-5.6.2/bin/./jmeter -n -t apache-jmeter-5.6.2/extras/Test.jmx

# Create an alias for convenience
echo 'alias jmeter="/tmp/apache-jmeter-5.6.2/bin/./jmeter"' >> ~/.bashrc
source ~/.bashrc
```

```
# jmeter -v    _    ____   _    ____ _   _ _____       _ __  __ _____ _____ _____ ____
   / \  |  _ \ / \  / ___| | | | ____|     | |  \/  | ____|_   _| ____|  _ \
  / _ \ | |_) / _ \| |   | |_| |  _|    _  | | |\/| |  _|   | | |  _| | |_) |
 / ___ \|  __/ ___ \ |___|  _  | |___  | |_| | |  | | |___  | | | |___|  _ <
/_/   \_\_| /_/   \_\____|_| |_|_____|  \___/|_|  |_|_____| |_| |_____|_| \_\ 5.6.2
Copyright (c) 1999-2023 The Apache Software Foundation

# jmeter -n -t /tmp/apache-jmeter-5.6.2/extras/Test.jmx. To run a sample test
Creating summariser <summary>
Created the tree successfully using /tmp/apache-jmeter-5.6.2/extras/Test.jmx
Starting standalone test @ 2023 Aug 11 23:05:29 UTC (1691795129771)
Waiting for possible Shutdown/StopTestNow/HeapDump/ThreadDump message on port 4445
Warning: Nashorn engine is planned to be removed from a future JDK release
summary +      1 in 00:00:00 =    3.1/s Avg:   271 Min:   271 Max:   271 Err:     0 (0.00%) Active: 1 Started: 1 Finished: 0
summary +     29 in 00:00:03 =    9.9/s Avg:   247 Min:   110 Max:   354 Err:     2 (6.90%) Active: 0 Started: 3 Finished: 3
summary =     30 in 00:00:03 =    9.2/s Avg:   248 Min:   110 Max:   354 Err:     2 (6.67%)
Tidying up ...    @ 2023 Aug 11 23:05:33 UTC (1691795133399)
... end of run
```

```
# jmeter -?
    _    ____   _    ____ _   _ _____       _ __  __ _____ _____ _____ ____
   / \  |  _ \ / \  / ___| | | | ____|     | |  \/  | ____|_   _| ____|  _ \
  / _ \ | |_) / _ \| |   | |_| |  _|    _  | | |\/| |  _|   | | |  _| | |_) |
 / ___ \|  __/ ___ \ |___|  _  | |___  | |_| | |  | | |___  | | | |___|  _ <
/_/   \_\_| /_/   \_\____|_| |_|_____|  \___/|_|  |_|_____| |_| |_____|_| \_\ 5.6.2
Copyright (c) 1999-2023 The Apache Software Foundation
        --?
                print command line options and exit
        -h, --help
                print usage information and exit
...

# jmeter -h
    _    ____   _    ____ _   _ _____       _ __  __ _____ _____ _____ ____
   / \  |  _ \ / \  / ___| | | | ____|     | |  \/  | ____|_   _| ____|  _ \
  / _ \ | |_) / _ \| |   | |_| |  _|    _  | | |\/| |  _|   | | |  _| | |_) |
 / ___ \|  __/ ___ \ |___|  _  | |___  | |_| | |  | | |___  | | | |___|  _ <
/_/   \_\_| /_/   \_\____|_| |_|_____|  \___/|_|  |_|_____| |_| |_____|_| \_\ 5.6.2

Copyright (c) 1999-2023 The Apache Software Foundation
To list all command line options, open a command prompt and type:
jmeter.bat(Windows)/jmeter.sh(Linux) -?                
...

# To run in GUI mode for test creation. The following opens an UI in WSL as well
jmeter
```

```
# To convert a Postman collection.json to collection.jmx
jmeter -n -t collection.jmx
```

- https://jmeter.apache.org/download_jmeter.cgi: This has the TGZ download.
- https://sudhakaryblog.wordpress.com/2020/06/23/apache-jmeter-in-wsl-ubuntu/
- https://linuxopsys.com/topics/install-apache-jmeter-on-ubuntu
