# Contributing

Contributions that improve container hardening, CI reliability, tests, or documentation are welcome.

## Development workflow

1. Create a focused branch from `main`.
2. Install dependencies with `npm ci`.
3. Run `npm test` and `npm run build`.
4. Build the production image with `docker build -t devboard:local .`.
5. Verify `curl --fail http://localhost:8080/healthz` against the running container.
6. Open a pull request that explains the change and any security trade-offs.

Keep pull requests small and avoid committing credentials, generated `dist` files, or local environment files. CI must pass before a change is merged.
