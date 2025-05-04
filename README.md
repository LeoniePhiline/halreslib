## Setup

### Set up `.env`

```console
cp .env.dist .env
```

Set `POSTGRES_PASSWORD`.

Set a `GITHUB_TOKEN` (used by `cargo-binstall` when building the `rust` container image). Setting this token prevents you from running into GitHub rate limits while installing Rust binary packages.

Optionally reduce `OLLAMA_CONTEXT_LENGTH` (e.g. to `4096`) and choose a smaller image than `"deepseek-r1:14b"` in `OLLAMA_MODEL`.

### TLS certificates

Install `mkcert` root certificate in the browser:

```console
mkcert -install
```

Generate a self-signed certificate for all hosts:

```console
mkcert '*.halreslib.test'
```

### Launch environment

Launch with:

```console
./scripts/docker/up.sh
```

Later shutdown with:

```console
./scripts/docker/down.sh
```

Follow logs with:

```console
# ./scripts/docker/logs.sh -f [SERVICE_NAME]
#
# E.g.:
./scripts/docker/logs.sh -f ollama
```
