class Agenthub < Formula
  desc "Single-binary control plane for long-lived AI agents"
  homepage "https://github.com/hawkingrei/agenthub"
  url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-0.0.1-source.tar.gz"
  sha256 "642d1a840bcf1a51905219c2318a49b6042a5c1b14bc64f9bb7b47c6c30cfa72"
  license "Apache-2.0"
  version "0.0.1"

  on_macos do
    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-0.0.1-darwin-arm64.tar.gz"
        sha256 "73d2fa986ad48b949702dc5d0e20aaf9c8ea3e8e778f5012ed40e0bfdde856ca"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-codex-acp-0.0.1-darwin-arm64.tar.gz"
        sha256 "fd58ae0b5504391fdcee43ddfa883da9bc660327ac66bb69e7d3694e2f68ebcb"
      end
    end
  end

  on_linux do
    on_intel do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-0.0.1-linux-amd64.tar.gz"
        sha256 "667ce8a1e3e6dcc71cf7a832c544ce3e86d5269ea96df5fe121cb61262e702b5"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-codex-acp-0.0.1-linux-amd64.tar.gz"
        sha256 "ef9838ce91c39d020d1e65b43be1a31e6e378d77af67c248141c899e20060f0a"
      end
    end

    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-0.0.1-linux-arm64.tar.gz"
        sha256 "dcfac7eccbfda2af3ee79d0a7171eef430265af32fbed6732677a8042111c2f7"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1/agenthub-codex-acp-0.0.1-linux-arm64.tar.gz"
        sha256 "3c6ede57a559aaa938bbcd603876799f92bab3af216f3c4243ca4fbbdf02a5fb"
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
