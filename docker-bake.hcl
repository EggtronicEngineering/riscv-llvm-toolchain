# Variables injected from CI
variable "DOCKER_REPO" {}
variable "X64_BUILDER_IMAGE" {}
variable "RISCV64_BUILDER_IMAGE" {}
variable "CI_COMMIT_TAG" {}

group "builders" {
  targets = ["x64-builder", "riscv64-builder"]
}

group "release" {
  targets = ["toolchain-release"]
}

target "x64-builder" {
  context = "docker/builders"
  dockerfile = "Dockerfile.x64-builder"
  output = ["type=registry"]
  tags = ["${X64_BUILDER_IMAGE}"]
  cache-from = ["type=registry,ref=${X64_BUILDER_IMAGE}-cache"]
  cache-to   = ["type=registry,ref=${X64_BUILDER_IMAGE}-cache,mode=max"]
}

target "riscv64-builder" {
  context = "docker/builders"
  dockerfile = "Dockerfile.riscv64-builder"
  output = ["type=registry"]
  tags = ["${RISCV64_BUILDER_IMAGE}"]
  cache-from = ["type=registry,ref=${RISCV64_BUILDER_IMAGE}-cache"]
  cache-to   = ["type=registry,ref=${RISCV64_BUILDER_IMAGE}-cache,mode=max"]
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
