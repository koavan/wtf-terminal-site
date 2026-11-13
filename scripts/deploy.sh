#!/usr/bin/env bash
# Upload the built site/ to the S3 bucket and invalidate CloudFront.
#
# Usage: scripts/deploy.sh [--build [path-to-wtf-terminal-checkout]]
#   --build   run scripts/build.sh first (otherwise the existing site/ is used)
# Env: AWS_PROFILE (default: personal), TOFU (default: tofu)
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

export AWS_PROFILE="${AWS_PROFILE:-personal}"
export AWS_PAGER=""
tofu="${TOFU:-tofu}"

if [ "${1:-}" = "--build" ]; then
  shift
  scripts/build.sh ${1:+"$1"}
fi
[ -f site/index.html ] || { echo "site/ is missing; run scripts/build.sh or pass --build" >&2; exit 1; }

bucket="$("$tofu" -chdir=infra/site output -raw bucket_name)"
dist="$("$tofu" -chdir=infra/site output -raw distribution_id)"
url="$("$tofu" -chdir=infra/site output -raw site_url)"

echo "Syncing site/ -> s3://$bucket (profile $AWS_PROFILE)"
# Assets: cached for a day. HTML and the sitemap: five minutes (and invalidated below).
aws s3 sync site/ "s3://$bucket" --delete \
  --exclude "*.html" --exclude "sitemap.xml*" \
  --cache-control "public,max-age=86400"
aws s3 sync site/ "s3://$bucket" --delete \
  --exclude "*" --include "*.html" --include "sitemap.xml*" \
  --cache-control "public,max-age=300"

echo "Invalidating CloudFront $dist"
aws cloudfront create-invalidation --distribution-id "$dist" --paths "/*" \
  --query 'Invalidation.[Id,Status]' --output text

echo "Deployed: $url"
