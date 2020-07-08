# S3toVolume

# Description
this container is built to pull a file down from s3 and place it in a location attached as a volume.

# build instructions
`docker build -t "registry.infra.fogops.io/liskl/s3tofile:latest" .;`
`docker push "registry.infra.fogops.io/liskl/s3tofile:latest";`


# requirements

requires aws credentials in one of three ways
### Oldest Less Secure Method: (setting the env variables manually)
```
push the following variables into the pod

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```


### AWS_instance role profile
  - create the role with perms into s3

### AWS EKS IAM Roles via Serviceaccounts (if in eks)
you need to add to the condition if you run in more than one namespace
```
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::1111111111:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/XXXXXXX"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringLike": {
        "oidc.eks.us-east-1.amazonaws.com/id/XXXXXXX:sub": "system:serviceaccount:NAMESPACE:*"
      }
    }
  }]
}
```

then create the role
need to create the serviceaccount for this if running this way.

# need to create role in AWS IAM that the pod will be able to assume.



NOTE:
in init-container you need to mount the volume into the container at /destination
