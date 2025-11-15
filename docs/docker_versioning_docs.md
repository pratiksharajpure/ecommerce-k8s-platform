# Docker Image Versioning Strategy

## Naming Convention
```
<registry>/<username>/<app-name>:<version>
```

**Example:** `docker.io/pratiksha3/ecommerce-app:v1.0.0`

---

## Version Tags

### Semantic Versioning
Follow the pattern: `vMAJOR.MINOR.PATCH`

- **MAJOR** (`v2.0.0`): Breaking changes that are not backward compatible
  - Example: Database schema changes, API redesign, removed features
  
- **MINOR** (`v1.1.0`): New features that are backward compatible
  - Example: New analytics dashboard, additional API endpoints
  
- **PATCH** (`v1.0.1`): Bug fixes and small improvements
  - Example: Security patches, performance improvements, bug fixes

### Environment-Specific Tags
- `dev` - Development builds (unstable, frequent updates)
- `staging` - Pre-production testing
- `prod` - Production-ready releases
- `latest` - Always points to the latest stable production release

### Traceability Tags
- **Git SHA**: `git-abc1234` - Links image to specific commit
- **Build Number**: `build-123` - CI/CD build identifier
- **Date**: `2025-11-15` - Build date for quick reference

---

## Build Process

### Development Build
```bash
# Build development image
docker build -t pratiksha3/ecommerce-app:dev .

# Push to Docker Hub
docker push pratiksha3/ecommerce-app:dev
```

### Staging Build
```bash
# Build release candidate
docker build -t pratiksha3/ecommerce-app:v1.0.0-rc1 .

# Tag for staging
docker tag pratiksha3/ecommerce-app:v1.0.0-rc1 pratiksha3/ecommerce-app:staging

# Push both tags
docker push pratiksha3/ecommerce-app:v1.0.0-rc1
docker push pratiksha3/ecommerce-app:staging
```

### Production Build
```bash
# Build production image
docker build -t pratiksha3/ecommerce-app:v1.0.0 .

# Tag as latest stable
docker tag pratiksha3/ecommerce-app:v1.0.0 pratiksha3/ecommerce-app:latest

# Tag as production
docker tag pratiksha3/ecommerce-app:v1.0.0 pratiksha3/ecommerce-app:prod

# Push all tags
docker push pratiksha3/ecommerce-app:v1.0.0
docker push pratiksha3/ecommerce-app:latest
docker push pratiksha3/ecommerce-app:prod
```

### Build with Git SHA (for traceability)
```bash
# Get current Git commit SHA
$GIT_SHA = git rev-parse --short HEAD

# Build with Git SHA tag
docker build -t pratiksha3/ecommerce-app:git-$GIT_SHA .

# Tag with version
docker tag pratiksha3/ecommerce-app:git-$GIT_SHA pratiksha3/ecommerce-app:v1.0.0

# Push both
docker push pratiksha3/ecommerce-app:git-$GIT_SHA
docker push pratiksha3/ecommerce-app:v1.0.0
```

---

## Version History

| Version | Date | Description | Breaking Changes |
|---------|------|-------------|------------------|
| v1.0.0 | 2025-11-15 | Initial production release | N/A |
| v1.0.1 | TBD | Bug fixes and improvements | No |
| v1.1.0 | TBD | New analytics features | No |
| v2.0.0 | TBD | Database schema update | Yes |

---

## Tagging Best Practices

### ✅ DO
- Always use semantic versioning for production releases
- Tag with `latest` only for stable production releases
- Include Git SHA for traceability
- Document breaking changes in version notes
- Test in staging before production
- Keep version history updated

### ❌ DON'T
- Don't overwrite existing version tags
- Don't use `latest` for development or unstable builds
- Don't skip versions (v1.0.0 → v1.0.2)
- Don't deploy to production without testing in staging
- Don't use vague tags like `final` or `new`

---

## Rollback Strategy

### Quick Rollback
```bash
# Rollback to previous version in Kubernetes
kubectl set image deployment/ecommerce-app streamlit=pratiksha3/ecommerce-app:v1.0.0

# Verify rollback
kubectl rollout status deployment/ecommerce-app
```

### Emergency Rollback
```bash
# Rollback to last known good version
kubectl rollout undo deployment/ecommerce-app

# Rollback to specific revision
kubectl rollout undo deployment/ecommerce-app --to-revision=2
```

---

## CI/CD Integration

### Automated Versioning Script
```bash
#!/bin/bash
# auto-version.sh

VERSION=$1
GIT_SHA=$(git rev-parse --short HEAD)
BUILD_DATE=$(date +%Y-%m-%d)

# Build image
docker build -t pratiksha3/ecommerce-app:${VERSION} .

# Tag with metadata
docker tag pratiksha3/ecommerce-app:${VERSION} pratiksha3/ecommerce-app:git-${GIT_SHA}
docker tag pratiksha3/ecommerce-app:${VERSION} pratiksha3/ecommerce-app:build-${BUILD_DATE}

# Push all tags
docker push pratiksha3/ecommerce-app:${VERSION}
docker push pratiksha3/ecommerce-app:git-${GIT_SHA}
docker push pratiksha3/ecommerce-app:build-${BUILD_DATE}

echo "✅ Built and pushed version ${VERSION}"
echo "   Git SHA: ${GIT_SHA}"
echo "   Build Date: ${BUILD_DATE}"
```

### GitHub Actions Example
```yaml
name: Build and Push Docker Image

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          push: true
          tags: |
            pratiksha3/ecommerce-app:${{ steps.version.outputs.VERSION }}
            pratiksha3/ecommerce-app:latest
```

---

## Image Cleanup Policy

### Retention Rules
- **Production versions**: Keep all (v1.0.0, v1.1.0, etc.)
- **Release candidates**: Keep last 3 (v1.0.0-rc1, rc2, rc3)
- **Development builds**: Keep last 10
- **Git SHA tags**: Keep last 50
- **Date tags**: Keep last 30 days

### Cleanup Script
```bash
# List all tags for repository
docker images pratiksha3/ecommerce-app --format "{{.Tag}}" | grep "^dev"

# Remove old dev images (keep last 10)
docker images pratiksha3/ecommerce-app --format "{{.Tag}}" | grep "^dev" | tail -n +11 | xargs -I {} docker rmi pratiksha3/ecommerce-app:{}
```

---

## Quick Reference Commands

```bash
# List all local images
docker images pratiksha3/ecommerce-app

# List all tags on Docker Hub (requires API or web interface)
# Visit: https://hub.docker.com/r/pratiksha3/ecommerce-app/tags

# Pull specific version
docker pull pratiksha3/ecommerce-app:v1.0.0

# Inspect image metadata
docker inspect pratiksha3/ecommerce-app:v1.0.0

# Check image size
docker images pratiksha3/ecommerce-app:v1.0.0 --format "{{.Size}}"
```

---

## Support & Contact

**Maintainer:** pratiksha3  
**Repository:** https://hub.docker.com/r/pratiksha3/ecommerce-app  
**Issues:** Report issues in project repository  

---

**Last Updated:** November 15, 2025  
**Document Version:** 1.0