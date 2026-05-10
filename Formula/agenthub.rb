class Agenthub < Formula
  desc "Single-binary control plane for long-lived AI agents"
  homepage "https://github.com/hawkingrei/agenthub"
  url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-0.0.4-source.tar.gz"
  sha256 "5cef01ff1904775b711d76a4be2ec709d3957abd63fac8da4a9942e673965c1f"
  license "Apache-2.0"
  version "0.0.4"

  on_macos do
    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-0.0.4-darwin-arm64.tar.gz"
        sha256 "4e484aa1e683d0eb9c4d4248a32b01e63913f0888f9e9db8f09624d80460bdcb"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-codex-acp-0.0.4-darwin-arm64.tar.gz"
        sha256 "2d865c50275d3f5ab353d5b09dcb609932c01fa347bb10248e8dc6a058002a03"
      end
    end
  end

  on_linux do
    on_intel do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-0.0.4-linux-amd64.tar.gz"
        sha256 "01e178d4b583b5a223486cf435bd302d62dc62c3c801415fa2a28c1cf6150905"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-codex-acp-0.0.4-linux-amd64.tar.gz"
        sha256 "6ca1ba0d1d625c2a929edcf24f8f128e631fcb0f2550685db17897d4b9547dec"
      end
    end

    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-0.0.4-linux-arm64.tar.gz"
        sha256 "2fb37f336318ad34bdcb55853455e823f6d7d469d7ffefc9f0010f4b650c04d3"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.4/agenthub-codex-acp-0.0.4-linux-arm64.tar.gz"
        sha256 "5af39c6319d6b7896a5436372a317e2a0f41c44cb79e4e9a1c696372e456342b"
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
