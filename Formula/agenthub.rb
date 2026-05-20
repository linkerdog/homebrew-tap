class Agenthub < Formula
  desc "Single-binary control plane for long-lived AI agents"
  homepage "https://github.com/hawkingrei/agenthub"
  url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-0.0.7-source.tar.gz"
  sha256 "2a0d6a829df3fd8054af98fbb5e463f70af553b852c5e2151c7b4cbfd31666ce"
  license "Apache-2.0"

  on_macos do
    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-0.0.7-darwin-arm64.tar.gz"
        sha256 "781e9aec7ed96246ba6591f2064f7d82fad2eb6da7d857601deff4b0236b66ef"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-codex-acp-0.0.7-darwin-arm64.tar.gz"
        sha256 "b77d4d314b45f1d7e8d93e777ed2a8d1828195c597b41d106cc789bfc1869161"
      end
    end
  end

  on_linux do
    on_intel do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-0.0.7-linux-amd64.tar.gz"
        sha256 "8783bf09920c47cb832b60b4b95ef7d76ee4fe08ba9bb83c0da4ccee30ec804d"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-codex-acp-0.0.7-linux-amd64.tar.gz"
        sha256 "82155c0692573df14bc7c850c40eaf02395f6ad71aebea2a8f0fab6746817aaa"
      end
    end

    on_arm do
      resource "agenthub-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-0.0.7-linux-arm64.tar.gz"
        sha256 "9a6242c3c055b3a53c754292f4dac281a1b700af766ea346918ad9ee3017a712"
      end

      resource "agenthub-codex-acp-bin" do
        url "https://github.com/hawkingrei/agenthub/releases/download/v0.0.7/agenthub-codex-acp-0.0.7-linux-arm64.tar.gz"
        sha256 "6fcc8ea8bfef04fb37ef9b5099e3ebfca5722f443e322e39e31743d0e189abb8"
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
