class Agenthub < Formula
  desc "Single-binary control plane for long-lived AI agents"
  homepage "https://github.com/hawkingrei/agenthub"
  url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-0.0.2-source.tar.gz"
  sha256 "43d00d537f1d752885ee48f8ac32abf6a3738aea5635c6dfc8966724d50991aa"
  license "Apache-2.0"
  version "0.0.2"

  on_macos do
    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-0.0.2-darwin-arm64.tar.gz"
        sha256 "2e8e0b9ac2433e661bcaebb644407a0c85146173a88cfe7c79a292a10654a774"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-codex-acp-0.0.2-darwin-arm64.tar.gz"
        sha256 "75b634a69e959c4e49fcfe809105ba621a0a16faef7629565e1b8f2af8fc1b27"
      end
    end
  end

  on_linux do
    on_intel do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-0.0.2-linux-amd64.tar.gz"
        sha256 "eaaac14f6356a2bec0bad883fba986de7eaa69bef8f43d82c64f3be828863072"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-codex-acp-0.0.2-linux-amd64.tar.gz"
        sha256 "925e2c0c7a3a770fa04535063acf4267629490db4951099cf2f3fa10869a1320"
      end
    end

    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-0.0.2-linux-arm64.tar.gz"
        sha256 "113afa4dd603cdf01ca895a7fcd3e9342dcf620bed92b019620e9d0b4a931a26"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.2/agenthub-codex-acp-0.0.2-linux-arm64.tar.gz"
        sha256 "eb9da5eb1c44eaacba5c0bda1fe4da45611d35be5deee606437cbfaeaa5a35ed"
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.intel?
      odie "AgentHub does not currently publish macOS Intel release binaries"
    end

    resource("agenthub-bin").stage do
      bin.install "agenthub"
      pkgshare.install "README.md" if File.exist?("README.md")
      pkgshare.install "LICENSE" if File.exist?("LICENSE")
    end

    resource("agenthub-codex-acp-bin").stage do
      bin.install "agenthub-codex-acp"
      (pkgshare/"agenthub-codex-acp").install "README.md" if File.exist?("README.md")
      (pkgshare/"agenthub-codex-acp").install "LICENSE" if File.exist?("LICENSE")
    end
  end

  def post_install
    mkdir_p var/"agenthub"
    mkdir_p var/"log"
  end

  service do
    run [opt_bin/"agenthub"]
    keep_alive true
    working_dir var/"agenthub"
    log_path var/"log/agenthub.log"
    error_log_path var/"log/agenthub.error.log"
  end

  def caveats
    <<~EOS
      AgentHub reads its runtime config from ~/.agenthub/config.toml.

      Minimal example:
        mkdir -p ~/.agenthub
        cat > ~/.agenthub/config.toml <<'EOF'
        [server]
        listen = "0.0.0.0:8080"
        EOF

      Start the background service with:
        brew services start #{name}

      The bundled ACP helper is also installed:
        #{opt_bin}/agenthub-codex-acp
    EOS
  end

  test do
    assert_match "AgentHub", shell_output("#{bin}/agenthub --help")
    assert_match "Usage", shell_output("#{bin}/agenthub-codex-acp --help")
  end
end
