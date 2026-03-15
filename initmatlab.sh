#!/bin/bash
mc cp s3/prantoine/matlab.yaml ~/work/matlab.yaml
kubectl apply -f ~/work/matlab.yaml
