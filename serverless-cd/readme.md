# Deployments

## Overview

This folder contains deployment scripts for the Scopone application using Serverless Framework v4.

## Deployment Scripts

### Deploy the Server as a Lambda Function

Move to the `server-lambda` folder and run:
```bash
bash deploy-server-to-lambda.sh
```

### Deploy the Angular Client to S3

Move to the `client-ng-s3` folder and run:
```bash
bash build-deploy-ng-front-end.sh
```

### Deploy the React Client to S3

Move to the `client-react-s3` folder and run:
```bash
bash build-deploy-react-front-end.sh
```

## Build and Deploy React App to AWS S3 Bucket as Static Web Server

### Build

From within `client-react` folder run the command `npm run build`.

### Deploy to S3

From within `client-react-s3` folder run the command `npx serverless client deploy`.

The serverless.yml configuration [serverless.yml](/client-react-s3/serverless.yml) contains the details of the configuration.

The redirect configuration should look like this:

```json
[
    {
        "Condition": {
            "HttpErrorCodeReturnedEquals": "404"
        },
        "Redirect": {
            "ReplaceKeyWith": ""
        }
    }
]
```

Please check since this is not currently supported by the `serverless-finch` plugin used to deploy. A PR has been raised but not yet accepted. In the meantime we rely on the package `serverless-finch-patched-for-redirect`.

## Dependencies

- **serverless**: ^4.23.0 (Latest v4)
- **serverless-finch-patched-for-redirect**: ^2.6.3
