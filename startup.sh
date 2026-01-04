#!/bin/bash
set -e

echo "Installing dependencies..."
pip install -r requirement.txt

echo "Starting Flask app..."
gunicorn --bind=0.0.0.0 --workers 1 --timeout 60 --access-logfile - --error-logfile - application:app
