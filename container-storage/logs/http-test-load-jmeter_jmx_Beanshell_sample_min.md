```
# To optionally create a working directory
mkdir /tmp/jmeter; cd /tmp/jmeter
```

```
# The test configuration is defined in the jmx file (quick_test.jmx). This is equivalent to the "curl http://23.97.247.10416" mentioned in HTTPSamplerProxy.
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.5">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Test Plan" enabled="true">
    </TestPlan>
    <hashTree>
      <ResultCollector guiclass="ViewResultsFullVisualizer" testclass="ResultCollector" testname="Results Tree" enabled="true">
        <boolProp name="ResultCollector.error_logging">true</boolProp>
        <objProp>
          <name>saveConfig</name>
          <value class="SampleSaveConfiguration">
            <time>true</time>
            <latency>true</latency>
            <timestamp>true</timestamp>
            <success>true</success>
            <label>true</label>
            <code>true</code>
            <message>true</message>
            <threadName>true</threadName>
            <dataType>true</dataType>
            <encoding>false</encoding>
            <assertions>true</assertions>
            <subresults>true</subresults>
            <responseData>false</responseData>
            <samplerData>false</samplerData>
            <xml>false</xml>
            <fieldNames>true</fieldNames>
            <responseHeaders>false</responseHeaders>
            <requestHeaders>false</requestHeaders>
            <responseDataOnError>false</responseDataOnError>
            <saveAssertionResultsFailureMessage>true</saveAssertionResultsFailureMessage>
            <assertionsResultsToSave>0</assertionsResultsToSave>
            <bytes>true</bytes>
            <sentBytes>true</sentBytes>
            <url>true</url>
            <threadCounts>true</threadCounts>
            <idleTime>true</idleTime>
            <connectTime>true</connectTime>
          </value>
        </objProp>
        <stringProp name="filename"></stringProp>
      </ResultCollector>
      <hashTree/>
      <ResultCollector guiclass="SummaryReport" testclass="ResultCollector" testname="Summary Report" enabled="true">
        <boolProp name="ResultCollector.error_logging">false</boolProp>
        <objProp>
          <name>saveConfig</name>
          <value class="SampleSaveConfiguration">
            <time>true</time>
            <latency>true</latency>
            <timestamp>true</timestamp>
            <success>true</success>
            <label>true</label>
            <code>true</code>
            <message>true</message>
            <threadName>true</threadName>
            <dataType>true</dataType>
            <encoding>false</encoding>
            <assertions>true</assertions>
            <subresults>true</subresults>
            <responseData>false</responseData>
            <samplerData>false</samplerData>
            <xml>false</xml>
            <fieldNames>true</fieldNames>
            <responseHeaders>false</responseHeaders>
            <requestHeaders>false</requestHeaders>
            <responseDataOnError>false</responseDataOnError>
            <saveAssertionResultsFailureMessage>true</saveAssertionResultsFailureMessage>
            <assertionsResultsToSave>0</assertionsResultsToSave>
            <bytes>true</bytes>
            <sentBytes>true</sentBytes>
            <url>true</url>
            <threadCounts>true</threadCounts>
            <idleTime>true</idleTime>
            <connectTime>true</connectTime>
          </value>
        </objProp>
        <stringProp name="filename">errors.log</stringProp>
      </ResultCollector>
      <hashTree/>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Thread Group" enabled="true">
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController" guiclass="LoopControlPanel" testclass="LoopController" testname="Loop Controller" enabled="true">
          <boolProp name="LoopController.continue_forever">false</boolProp>
          <stringProp name="LoopController.loops">15000</stringProp>
        </elementProp>
        <stringProp name="ThreadGroup.num_threads">20</stringProp>
        <stringProp name="ThreadGroup.ramp_time">0</stringProp>
      </ThreadGroup>
      <hashTree>
        <HeaderManager guiclass="HeaderPanel" testclass="HeaderManager" testname="HTTP Header Manager" enabled="true">
        </HeaderManager>
        <hashTree/>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="HTTP Request" enabled="true">
          <boolProp name="HTTPSampler.postBodyRaw">true</boolProp>
          <stringProp name="HTTPSampler.domain">23.97.247.10416</stringProp>
          <stringProp name="HTTPSampler.port"></stringProp>
          <stringProp name="HTTPSampler.protocol">http</stringProp>
          <stringProp name="HTTPSampler.path">/</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
          <boolProp name="HTTPSampler.follow_redirects">true</boolProp>
        </HTTPSamplerProxy>
        <hashTree/>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

```
# To run the load test and view recent summaries
rm *.log ## To ensure it does not use values of an earlier test
jmeter -n -t quick_test.jmx -f -l results.log
cat jmeter.log | tail
cat results.log | tail
cat errors.log | tail ## If errors
```

```
# Here is a sample output below.

Creating summariser <summary>
Created the tree successfully using quick_test.jmx
Starting standalone test @ 2023 Aug 12 12:51:05 UTC (1691844665502)
Waiting for possible Shutdown/StopTestNow/HeapDump/ThreadDump message on port 4445
Warning: Nashorn engine is planned to be removed from a future JDK release
summary +      1 in 00:00:00 =    6.1/s Avg:    47 Min:    47 Max:    47 Err:     1 (100.00%) Active: 20 Started: 20 Finished: 0
summary + 299999 in 00:00:04 = 70142.4/s Avg:     0 Min:     0 Max:    54 Err: 299999 (100.00%) Active: 0 Started: 20 Finished: 20
summary = 300000 in 00:00:04 = 67567.6/s Avg:     0 Min:     0 Max:    54 Err: 300000 (100.00%)
Tidying up ...    @ 2023 Aug 12 12:51:10 UTC (1691844670222)
... end of run

2023-08-12 12:25:10,037 INFO o.a.j.r.Summariser: summary + 299999 in 00:00:05 = 66268.8/s Avg:     0 Min:     0 Max:    40 Err: 299999 (100.00%) Active: 0 Started: 20 Finished: 20

timeStamp,elapsed,label,responseCode,responseMessage,threadName,dataType,success,failureMessage,bytes,sentBytes,grpThreads,allThreads,URL,Latency,IdleTime,Connect
1691843110035,0,HTTP Request,Non HTTP response code: java.net.UnknownHostException,Non HTTP response message: 23.97.247.10416,Thread Group 1-15,text,false,,2210,0,1,1,http://23.97.247.10416/,0,0,0

timeStamp,elapsed,label,responseCode,responseMessage,threadName,dataType,success,failureMessage,bytes,sentBytes,grpThreads,allThreads,URL,Latency,IdleTime,Connect
1691843110035,0,HTTP Request,Non HTTP response code: java.net.UnknownHostException,Non HTTP response message: 23.97.247.10416,Thread Group 1-15,text,false,,2210,0,1,1,http://23.97.247.10416/,0,0,0
```

```
# cat /tmp/repro-502/jmeter/results.log | grep ,502,
1691813852206,129,HTTP Request,502,Bad Gateway,Thread Group 1-15,text,false,,366,16755,20,20,http://23.97.247.104/,128,0,43

# cat /tmp/repro-502/jmeter/results.log | grep ,502, | wc -l
1

# ls /tmp/jmeter
errors.log  jmeter.log  quick_test.jmx  results.log
```

- https://www.blazemeter.com/blog/jmeter-properties-customization
