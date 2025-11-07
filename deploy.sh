#!/bin/bash
echo "Starting TAO deployment..."
docker-compose -f docker-compose-dev.yml up -d
echo ""
echo "✅ TAO is starting..."
echo "⏳ Please wait 3-5 minutes for full initialization"
echo ""
echo "🌐 Access at: http://localhost/tao/install"
echo ""
echo "Database Configuration:"
echo "  Host: database"
echo "  Database: tao"
echo "  User: tao"
echo "  Password: tao"
