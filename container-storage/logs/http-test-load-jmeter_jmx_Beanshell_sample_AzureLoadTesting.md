Azure Load Testing can be utilized to generate and execute a JMeter test plan using the "Create a new test" feature. The test can subsequently be modified to access the contents of the JMX file, allowing for further customization as needed.

Here are the step-by-step instructions for using Azure Load Testing:

1. <b>Creating a New Test</b>:
- Open Azure Load Testing.
- Choose the "Create a new test" option.
- Specify the Test URL. For instance, input "http://23.97.247.104".
- Initiate the test by clicking on the "Run Test" button.
2. <b>Accessing and Editing Test Plan</b>:
- Navigate to Azure Load Testing.
- Locate the "Tests" section and click on the desired test.
- Access the configuration options by selecting "Configure."
- Within the "Test" settings, find the "Test Plan" containing the JMX file.
- The JMX file encompasses values like "${__P(ip_address,52.137.5.92)}", "http", or parameters enclosed in parentheses such as "${domain}", omitting the quotation marks.

<br>
- https://learn.microsoft.com/en-us/azure/load-testing/how-to-create-and-run-load-test-with-jmeter-script
