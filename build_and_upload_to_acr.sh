#!/bin/bash

cd /d/BA_Aiman/AzureTraining/AppService/nubesgen_test/src

echo "current working directory: $(pwd)"

cd backend

az acr build --registry crdemo28723146dev --image backend_image:latest .

cd ../frontend

az acr build --registry crdemo28723146dev --image frontend_image:latest .
