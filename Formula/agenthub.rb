class Agenthub < Formula
  desc "Single-binary control plane for long-lived AI agents"
  homepage "https://github.com/hawkingrei/agenthub"
  url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-0.0.1-beta1-source.tar.gz"
  sha256 "641b1fbb85863fa4a7869d4efad2c702971ed9e59cd6b645ed4d96bbbe5110cc"
  license "Apache-2.0"
  version "0.0.1-beta1"

  on_macos do
    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-0.0.1-beta1-darwin-arm64.tar.gz"
        sha256 "0ba1118a14138e944cdf5cd6410ee887a21156b13817e0c4d872dd439dfe18a0"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-codex-acp-0.0.1-beta1-darwin-arm64.tar.gz"
        sha256 "c73a83c0f3afc0621872c3b752ec50a7a6b72f64da1fbb7730a7e7395ad9a38f"
      end
    end
  end

  on_linux do
    on_intel do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-0.0.1-beta1-linux-amd64.tar.gz"
        sha256 "43659107d147d666ae00876313351ded7bbfbf3e33260fdc0c3c230245ba7765"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-codex-acp-0.0.1-beta1-linux-amd64.tar.gz"
        sha256 "a38bd2b50d2333d61bedf05ed33c8a7cb681348207b4c2e4676e69c0f52f8d45"
      end
    end

    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-0.0.1-beta1-linux-arm64.tar.gz"
        sha256 "f8524e148add8c7ca7519a14226e0c1ce02c88af162ca3c34c6fb0ce6d750624"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.1-beta1/agenthub-codex-acp-0.0.1-beta1-linux-arm64.tar.gz"
        sha256 "2fc4ee88deab2d54375ad2b4a36fd42eb08e12642606036bbcdd478d41ea8768"
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
