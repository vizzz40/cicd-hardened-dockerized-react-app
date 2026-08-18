<div align="center">
  <h1>Docker Image Hardening & CI Security</h1>
  <p><strong>Container optimization and security automation for a React application.</strong></p>
  <p>
    <a href="https://github.com/vizzz40/cicd-hardened-dockerized-react-app/actions/workflows/ci.yml"><img src="https://github.com/vizzz40/cicd-hardened-dockerized-react-app/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
    <img src="https://img.shields.io/badge/runtime-non--root-2ea44f" alt="Non-root runtime">
    <img src="https://img.shields.io/badge/image-7.65_MB-7f77dd" alt="7.65 MB image">
  </p>
</div>

## Project overview

I containerized and hardened a React application, reduced its production image size, analyzed image vulnerabilities, configured a non-root NGINX runtime, and added automated build and security checks with GitHub Actions.

## What I implemented

- Reworked the Docker build to cache dependency installation and avoid a slow recursive ownership change.
- Separated the Node.js build environment from the production runtime with a multi-stage build.
- Served only the compiled static files from a shell-free, non-root Chainguard NGINX image.
- Added SPA routing, security headers, and a `/healthz` endpoint through NGINX.
- Compared the images with Docker Scout and recorded the size and vulnerability changes.
- Added GitHub Actions checks for the application build, tests, Gitleaks, and Trivy.

## Results

| Image | Size | Critical | High | Medium | Low |
| --- | ---: | ---: | ---: | ---: | ---: |
| Original Node runtime | 538 MB | 5 | 43 | 44 | 7 |
| Multi-stage Node runtime | 380 MB | 0 | 1 | 2 | 2 |
| Docker Hardened Image experiment | 53.9 MB | 0 | 5 | 6 | 26 |
| Current Chainguard NGINX runtime | **7.65 MB** | **0** | **0** | **0** | **0** |

The current image runs as UID `65532`. One observed build also improved from `240.4 s` to `60.1 s` after ownership was applied during `COPY` instead of through a recursive `chown`.

These figures are dated local observations. Image sizes vary by platform, build timings depend on the machine and cache state, and vulnerability results change as scanner databases are updated.

![Docker image size comparison](docs/evidence/image-sizes.png)

<details>
<summary><strong>Docker Scout screenshots</strong></summary>

### Original image

![Docker Scout scan of the original image](docs/evidence/scout-full.png)

### Multi-stage image

![Docker Scout scan of the multi-stage image](docs/evidence/scout-multistage.png)

### Docker Hardened Image experiment

![Docker Scout scan of the DHI image](docs/evidence/scout-dhi.png)

</details>

<details>
<summary><strong>Build-time screenshots</strong></summary>

### Before

![Docker build before the ownership change](docs/evidence/build-before.png)

### After

![Docker build after the ownership change](docs/evidence/build-after.png)

</details>

## Container design

```text
React source -> Node 24 build stage -> compiled /dist files
                                         |
                                         v
                              non-root NGINX runtime
```

The default `Dockerfile` is the current production build. The other Dockerfiles preserve earlier hardening experiments for comparison.

## CI workflow

Both jobs run on GitHub-hosted Ubuntu runners, so the workflow does not require a self-hosted machine. On pushes and pull requests to `main`, GitHub Actions:

1. Installs locked dependencies with `npm ci`.
2. Runs the test suite, creates the production build, and uploads the compiled files as a workflow artifact.
3. Scans the repository with Gitleaks and Trivy.
4. Builds the Docker image and scans it with Trivy for high and critical vulnerabilities.

## Run locally

```bash
docker build -t react-app:local .
docker run --rm -p 8080:8080 react-app:local
curl --fail http://localhost:8080/healthz
```
