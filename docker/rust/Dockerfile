FROM amd64/rust:1.86.0-slim-bookworm@sha256:5265cf7f0324e5af0d0af625952b426cfaf5fc6daafd79b1fdedac07bd69b999

# "$GITHUB_TOKEN" is used by `cargo-binstall` to authenticate against the GitHub API,
# as not to hit GitHub's API request rate limits.
ARG GITHUB_TOKEN

ARG UID
ARG GID

ENV RUSTUP_HOME="/usr/local/rustup" \
    CARGO_HOME="/usr/local/cargo" \
    PATH="/usr/local/cargo/bin:$PATH" \
    CARGO_TERM_COLOR="always"

SHELL ["/bin/bash", "-c"]

RUN <<EOF
set -e
set -u
set -x
set -o pipefail
set -E

export DEBIAN_FRONTEND=noninteractive

apt update
apt dist-upgrade --assume-yes --option "Dpkg::Options::=--force-confold" --option "Dpkg::Options::=--force-confdef" --allow-downgrades --allow-remove-essential --allow-change-held-packages

# Build deps for `openssl-sys` (used by `nextest-runner`): libssl-dev, pkg-config
apt install -y --no-install-recommends git libssl-dev pkg-config

# Build mold from source
git clone https://github.com/rui314/mold.git
mkdir mold/build
cd mold/build

# Using https://docs.renovatebot.com/presets-customManagers/#custommanagersdockerfileversions
# renovate: datasource=github-releases depName=rui314/mold versioning=semver
git checkout v2.38.1
../install-build-deps.sh
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ ..
cmake --build . -j $(nproc)
cmake --build . --target install
rm -rf mold

# Install rust and cargo tools
rustup update
rustup component add llvm-tools
rustup component add rustfmt
rustup component add clippy
cargo install cargo-binstall
cargo binstall --no-confirm cargo-cache@0.8.3
cargo binstall --no-confirm cargo-insta@1.43.1
cargo binstall --no-confirm cargo-llvm-cov@0.6.16
cargo binstall --no-confirm cargo-nextest@0.9.95
cargo binstall --no-confirm watchexec-cli@2.3.0
cargo cache --autoclean-expensive

# Create unprivileged user
addgroup --gid "${GID}" rust
adduser --uid "${UID}" --ingroup rust --disabled-password --gecos '' rust
EOF

# Configure cargo to link using mold
# https://doc.rust-lang.org/cargo/reference/config.html#hierarchical-structure
COPY config.toml /.cargo/config.toml

# After installing toolchain, rustup components and cargo plugins into `/usr/local/cargo/`,
# create the later-cached cargo home under the unprivileged /home/rust directory.
#
# When working with this base image manually, mount your project under `/workspace`.
#
# Cargo will search for toolchains, components and cargo plugins
# in `$CARGO_HOME` and fall back to `/usr/local/cargo/`.
#
# The global `/usr/local/cargo/` will be static within the base container,
# while, in CI, the user's `$CARGO_HOME` should be configured to be uploaded
# into the GitLab cache.
#
# As only paths within `$CI_PROJECT_DIR` can be cached,
# projects using this base image **must** re-declare `$CARGO_HOME`
# to lie within the job's working directory!
ENV CARGO_HOME="/workspace/.cargo"
ENV CARGO_TARGET_DIR="/workspace/.target"

RUN <<EOF
set -e
set -u
set -x
set -o pipefail
set -E

mkdir /workspace
chown rust:rust /workspace
EOF

USER rust

WORKDIR /workspace

VOLUME /workspace
VOLUME /workspace/.cargo
VOLUME /workspace/.target

ENV RUST_BACKTRACE="full"
ENV RUST_LOG="debug"

RUN <<EOF
set -e
set -u
set -x
set -o pipefail
set -E

# Prepare unprivileged cargo home.
mkdir -p "${CARGO_HOME}"

# Prepare target dir independent of host target
# used by e.g. `rust-analyzer`.
mkdir -p "${CARGO_TARGET_DIR}"

# Prepare unprivileged entrypoint dir.
mkdir -p /home/rust/.local/bin
EOF

COPY ./entrypoint.sh /home/rust/.local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/bin/bash" ]
CMD [ "/home/rust/.local/bin/entrypoint.sh" ]
