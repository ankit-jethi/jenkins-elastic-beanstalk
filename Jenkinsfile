pipeline {
    agent any
    environment {
        VERSION_LABEL = "v$BUILD_NUMBER"
        BUCKET_NAME = "pyhton-news-app-eb-source"
        APP_NAME = "python-news-app"
        ENVIRONMENT_NAME = "python-news-app-staging"
        ZIP_NAME = "$APP_NAME-${VERSION_LABEL}.zip"
        REGION = "us-east-1"
    }
   stages {
      stage('Upload code to S3') {
         steps {
            sh 'zip -r $ZIP_NAME * && \
            aws s3 cp $ZIP_NAME s3://$BUCKET_NAME && \
            rm -f $ZIP_NAME'
         }
      }
      stage('Create new EB application version') {
         steps {
             sh 'aws elasticbeanstalk create-application-version \
             --application-name "$APP_NAME" \
             --version-label "$VERSION_LABEL" \
             --description "Build created from Jenkins." \
             --source-bundle S3Bucket=$BUCKET_NAME,S3Key=$ZIP_NAME \
             --auto-create-application \
             --region $REGION'
         }
      }
      stage('Update EB environment') {
         steps {
             sh 'aws elasticbeanstalk update-environment \
             --environment-name "$ENVIRONMENT_NAME" \
             --version-label "$VERSION_LABEL" \
             --region $REGION'
         }
      }      
   }
}
