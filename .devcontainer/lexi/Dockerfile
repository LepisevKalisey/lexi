# LEXI stand image: Chatwoot's devcontainer image (.devcontainer/Dockerfile) with two changes.
# 1. The base image carries the GitHub CLI apt source with a rotated signing key, so every
#    apt-get update fails (NO_PUBKEY 5612B36462313325) and the sshd feature cannot install.
# 2. Only dependency manifests are copied: the repository is mounted at /workspace at runtime,
#    and enterprise/ stays out of the image layers too.
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

USER root
RUN grep -l 'cli.github.com' /etc/apt/sources.list.d/* 2>/dev/null | xargs -r rm -f
USER vscode

WORKDIR /workspace
COPY package.json pnpm-lock.yaml ./
COPY Gemfile Gemfile.lock ./
RUN pnpm install --frozen-lockfile && \
    gem install bundler && \
    bundle install --jobs=$(nproc)
