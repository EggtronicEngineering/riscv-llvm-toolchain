# Variables injected from CI
variable "DOCKER_REPO" {}
variable "LINUX_BUILDER_IMAGE" {}
variable "WINDOWS_BUILDER_IMAGE" {}
variable "CI_COMMIT_TAG" {}

group "builders" {
  targets = ["linux-builder", "windows-builder"]
}

group "release" {
  targets = ["toolchain-release"]
}

target "linux-builder" {
  context = "docker/builders"
  dockerfile = "Dockerfile.linux-builder"
  output = ["type=registry"]
  tags = ["${LINUX_BUILDER_IMAGE}"]
  cache-from = ["type=registry,ref=${LINUX_BUILDER_IMAGE}-cache"]
  cache-to   = ["type=registry,ref=${LINUX_BUILDER_IMAGE}-cache,mode=max"]
}

target "windows-builder" {
  context = "docker/builders"
  dockerfile = "Dockerfile.windows-builder"
  output = ["type=registry"]
  tags = ["${WINDOWS_BUILDER_IMAGE}"]
  cache-from = ["type=registry,ref=${WINDOWS_BUILDER_IMAGE}-cache"]
  cache-to   = ["type=registry,ref=${WINDOWS_BUILDER_IMAGE}-cache,mode=max"]
}

target "toolchain-release" {
  context = "."
  dockerfile = "docker/release/Dockerfile.release"
  output = ["type=registry"]
  # TARGETARCH injection
  platforms = ["linux/amd64","linux/riscv64"]
  tags = [
    "${DOCKER_REPO}:${CI_COMMIT_TAG}",
    "${DOCKER_REPO}:latest"
  ]
}
