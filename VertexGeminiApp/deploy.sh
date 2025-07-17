#!/bin/bash

# Cloud Run deployment script for Gemini Chat App

set -e

# Configuration
PROJECT_ID="sesac-dev-400904"
SERVICE_NAME="gemini-chat-app"
REGION="us-central1"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Starting Cloud Run deployment..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

# Set the project
echo "📋 Setting project to $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable aiplatform.googleapis.com

# Build and push the image
echo "🏗️  Building and pushing Docker image..."
gcloud builds submit --tag $IMAGE_NAME

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --set-env-vars "PROJECT_ID=$PROJECT_ID,LOCATION=$REGION" \
    --memory 512Mi \
    --cpu 1 \
    --timeout 300 \
    --concurrency 80

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')

echo "✅ Deployment completed successfully!"
echo "📱 Service URL: $SERVICE_URL"
echo "🔗 Health check: $SERVICE_URL/health"
echo ""
echo "📝 Next steps:"
echo "1. Update your Android app to use this URL: $SERVICE_URL"
echo "2. Test the connection: curl $SERVICE_URL/health"
echo "3. Update ChatRepository.kt baseUrl to: $SERVICE_URL/"