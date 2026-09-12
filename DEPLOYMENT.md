# 🚀 EstheBook GitHub Pages Deployment Guide

## Overview

This project is configured to automatically deploy to GitHub Pages when you push to the `main` branch. The deployment is fully automated using GitHub Actions.

## Automatic Deployment (GitHub Actions)

### How It Works

1. **Trigger**: Push to `main` branch or manually trigger via **Actions → Deploy to GitHub Pages → Run workflow**
2. **Build Process**:
   - Checks out code
   - Sets up Flutter
   - Runs `flutter pub get`
   - Runs analyzer and tests
   - Builds web app with: `flutter build web --release --base-href /<repo-name>/`
   - Creates 404.html fallback for deep linking
   - Creates .nojekyll to prevent Jekyll processing
   - Uploads build artifacts to GitHub Pages
3. **Deployment**: Automatically deploys to `https://<username>.github.io/<repo-name>/`

### GitHub Pages Configuration

Ensure your repository is configured correctly:

1. Go to **Settings → Pages**
2. Set **Source** to "GitHub Actions"
3. Leave the **Branch** selection as is (not needed when using Actions)

### Workflow Details

**File**: `.github/workflows/deploy.yml`

Key improvements in the workflow:
- ✅ Uses `${{ github.repository }}` to reliably extract repository name (works with both `push` and `workflow_dispatch` triggers)
- ✅ Explicitly sets up GitHub Pages environment
- ✅ Enables Flutter Web support
- ✅ Includes analyzer and tests before deployment
- ✅ Creates 404.html fallback for deep linking support
- ✅ Disables Jekyll processing with .nojekyll

## Local Development

### Build Locally

```bash
# Enable Flutter Web (if not already enabled)
flutter config --enable-web

# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d chrome

# Build for release
flutter build web --release --base-href /EstheBook/
```

### Web-Specific Configuration

**web/index.html**:
- Uses `$FLUTTER_BASE_HREF` variable (automatically replaced by Flutter build)
- Includes custom splash screen with EstheBook branding
- Responsive viewport configuration
- PWA manifest link

**web/manifest.json**:
- PWA configuration with start_url: "./" (relative path for subpath deployment)
- Custom theme colors matching EstheBook design system
- App icons for installation

## Troubleshooting

### Issue: 404 Error When Accessing Live Site
**Solution**: The workflow includes a 404.html fallback that serves index.html. Deep links like `/discover/clinic/c1` should work after refresh.

### Issue: Assets Not Loading
**Verify**:
1. `--base-href /<repo-name>/` is set in build command
2. `.nojekyll` file exists in build output (prevents Jekyll from ignoring `assets/` folder)
3. Files starting with `_` (like `_dart_binaries`) are not being processed by Jekyll

### Issue: Service Worker Errors
The Flutter build automatically handles service worker generation. If issues occur:
1. Clear browser cache
2. Check browser DevTools → Application → Service Workers
3. Try hard refresh (Ctrl+Shift+R or Cmd+Shift+R)

### Issue: Routing Not Working (404 on Deep Links)
This is handled by the 404.html fallback created in the workflow. Ensure:
1. `copy build/web/index.html build/web/404.html` runs in workflow
2. GitHub Pages is configured to deploy from Actions

## Performance Tips

1. **Disable Tests for Faster Deployment**: Comment out or remove the test step if you don't need it
2. **Cache Dependencies**: The workflow uses `cache: true` for Flutter setup
3. **Optimize Assets**: Ensure assets in `assets/data/` and icons are optimized

## Next Steps (V2 Roadmap)

- Add Caching Headers configuration
- Set up preview deployments for PRs
- Add lighthouse performance checks
- Integrate analytics tracking
- Set up custom domain support

## References

- [Flutter Web Build Documentation](https://flutter.dev/docs/deployment/web)
- [GitHub Pages with GitHub Actions](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#publishing-sources-for-github-pages-sites)
- [go_router Deep Linking](https://pub.dev/packages/go_router#deep-linking)
