#!/bin/bash

echo "👑 EMPRESS Mutation Protocol Starting..."

# Fallback: Git remote
git remote get-url origin >/dev/null 2>&1 || git remote add origin https://github.com/72X72/empress-cockpit.git

# Fallback: Git branch
git rev-parse --abbrev-ref HEAD | grep -q main || git branch -M main

# Push to GitHub
git push -u origin main

# Fallback: AWS credentials
aws sts get-caller-identity >/dev/null 2>&1 || { echo "🔐 Inject IAM credentials with aws configure"; exit 1; }

# Fallback: S3 throne bucket
aws s3api head-bucket --bucket empress-throne 2>/dev/null || aws s3api create-bucket --bucket empress-throne --region us-east-1

# Encrypt throne
aws s3api put-bucket-encryption --bucket empress-throne --server-side-encryption-configuration '{
  "Rules": [{
    "ApplyServerSideEncryptionByDefault": {
      "SSEAlgorithm": "AES256"
    }
  }]
}'

# Narrate mutation
echo "Mutation: fullsync at $(date)" >> mutation.log
aws s3 cp mutation.log s3://empress-throne/mutation-$(date +%s).log --sse AES256

echo "✅ EMPRESS Mutation Complete. Throne Synced, Git Sovereign, Narration Logged."
