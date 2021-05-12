# Kinesis Binance Streamer - Data Engineering 5 @ CEU 2020-2021

## By [Cosmin Catalin Ticu](https://github.com/cosmin-ticu)

This [GitHub repository](https://github.com/cosmin-ticu/kinesis-binance-streamer/) contains all the codes used in creating the AWS Kinesis streamer of the Binance crypto live-trading dataset for the final assignment of the DE5 course.

The codes were written on a custom AWS AMI EC2 instance of t3.small type. RStudio was used for script creation and terminal commands, while Jenkins was used as an orchestration and scheduling tool to run the [Slack-enabled analytics script](https://github.com/cosmin-ticu/kinesis-binance-streamer/blob/main/get_all_coins.R). The app.properties file cotains instructions for the Java daemon to initialize the AWS Kinesis stream with the EC2 instance's locally loaded authorized AWS credentials. The Kinesis consumer app.R initializes the stream, writes to a Redis key-value store DB and keeps a log of every identified transaction as well as the stream's health. The analytics script acts on the live streamer data to send automated Slack messages and visualizations of Binance trading data to a proprietary Slack channel.

Special credits go to:
* [Gergely Daróczi](https://github.com/daroczig) - provided skeleton of the codes and guidance to conduct the R script productionizing during his course
* [Kata Süle](https://github.com/sulekata) - helped create the productionized data processor application
