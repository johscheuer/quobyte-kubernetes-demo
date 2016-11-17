#!/bin/bash

todos=(
    'eat' 
    'sleep' 
    'code' 
    'Quobyte'
    'Kubernetes'
    'Stuff')

for todo in "${todos[@]}"; do
    echo "Adding todo ${todo}"
    curl -s localhost:8001/api/v1/proxy/namespaces/todo-app/services/todo-app/insert/todo/$todo > /dev/null
done