# AWS Elastic Beanstalk and Jenkins
Deploying a python app using Jenkins to learn AWS Elastic Beanstalk

>I did not write the python code.

### How to setup:
- Install AWS CLI and configure it. (Permissions - Access to an S3 bucket and Elastic Beanstalk)
- Create an S3 bucket to store application source bundles.
- Setup a load-balanced enviroment in Elastic Beanstalk with a sample python application. (Please refer to the **rolling-updates-deployments.config** below for the reason behind load-balanced environment)
- Update the Environment variables in the Jenkinsfile with the bucket name, app name and the environment name.
- Build the Jenkins pipeline.

### The Elastic Beanstalk environment has been configured using these config files:

#### Under the .ebextensions directory:

- [python-news-app.config](../master/.ebextensions/python-news-app.config)

\- To serve static content from nginx.  
\- To setup the WSGIPath.  
\- To change the gunicorn workers & threads.

- [logs-cloudwatch.config](../master/.ebextensions/logs-cloudwatch.config) (Customise it to push other logs) 

\- This installs and configures the AWS CloudWatch Logs agent to push specified logs to a Log Group.  
\- The Log Group name will follow this format: **/aws/elasticbeanstalk/\<environment name>/\<full log name path>**  
\- Currently it sends these logs: **/var/log/messages** & **/var/log/dmesg**

>The default instance profile - **aws-elasticbeanstalk-ec2-role** lacks the permission to create log groups. So add a policy for that.
```
# Example policy:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0", 
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"
        }
    ]
}
```

- [rolling-updates-deployments.config](../master/.ebextensions/rolling-updates-deployments.config) 
>This requires a load-balanced environment. **It will fail if deployed in a single instance environment**. So either deploy it in a load-balanced environment or remove this config file before deploying.

It will configure your environment to use rolling updates for:  
\- Configuration updates that require instances to be replaced.  
\- And for version deployments.

#### Under the .platform/nginx directory:
- [nginx.conf](../master/.platform/nginx/nginx.conf) - Replacing the global nginx config file for performance optimizations regarding sendfile, tcp_nopush & gzip.

### Bonus:
- This app can also be deployed directly to an EC2 instance. 
- A shell script has been included for the installation on an Amazon Linux 2 instance.
- The script will also setup a systemd service so that the application will automatically start at boot.

#### Under the install directory:
- [setup.sh](../master/install/setup.sh) - Installation script.
- [python-news-app.service](../master/install/python-news-app.service) - Systemd service.

The application by default runs on a gunicorn server on port **8000** with 4 workers.  
Gunicorn log files:  
\- Access log - **/var/log/python-news-app/gunicorn/gunicorn_access.log**   
\- Error log - **/var/log/python-news-app/gunicorn/gunicorn_error.log**

### Sources:
1. [Tutorials and sample applications including python](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/tutorials.html)
2. [Elastic Beanstalk instance profile](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles-instance.html)
3. [Extending Linux platforms](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html)
4. [Using the Elastic Beanstalk Python platform](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-python-container.html)
5. [Create an application source bundle](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/applications-sourcebundle.html)
6. [Rolling updates](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.rollingupdates.html)
7. [Configuring Elastic Beanstalk environments (advanced)](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/beanstalk-environment-configuration-advanced.html)
8. [Log Streaming feature](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.cloudwatchlogs.html)
9. [Systemd Service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
10. [Gunicorn Documentation](http://docs.gunicorn.org/)
