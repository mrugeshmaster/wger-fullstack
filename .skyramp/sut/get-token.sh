#!/usr/bin/env bash
set -euo pipefail

# wger 2.7+ removed the /api/v2/login/ HTTP endpoint.
# Use python3 -c with django.setup() directly — no manage.py startup messages on stdout.
docker compose -f .skyramp/sut/docker-compose.yml exec -T web \
  python3 -c "
import sys, os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings.main')
import django
django.setup()
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
user = User.objects.get(username='admin')
token, _ = Token.objects.get_or_create(user=user)
sys.stdout.write(token.key)
" 2>/dev/null
