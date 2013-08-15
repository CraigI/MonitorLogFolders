MonitorLogFolders
=================

PowerShell Script used to monitor log folder sizes and send alerts when over a certain size

Please see: http://it-erate.com/powershell-monitoring-size-log-folders for further details on how to
configure this script.

Main Files
==================
MonitorLogFolders.ps1 – This is the main script that does the work.
LogPaths.csv – Place all of the UNC paths of any server you would like to monitor.
Record.csv – Historical record of the script running and path sizes.
Settings.ini – Some other information you can configure such as email addresses and what size a log folder must be before sending out an alert (in MB).

Usage
==================
In order to correctly monitor log folders you will need to either use a scheduled task or some other system that allows you to
run scripts on a scheduled interval.


About Us
=================
Please stop by and see other things we have going on at IT-erate.com. We hope that you found this script helpful and if so please stop by and
let us know!