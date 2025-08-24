class AirprintBridge < Formula
  desc "Enable AirPrint functionality for non-AirPrint printers on macOS"
  homepage "https://github.com/sapireli/AirPrint_Bridge"
  url "https://github.com/sapireli/AirPrint_Bridge/archive/refs/heads/main.tar.gz"
  version "1.3.2"
  sha256 "e2abfdd61c32d35359e924dd8d8476a53a25b71768f60c7be08582a0fe7fd624"
  license "MIT"

  depends_on :macos

  def install
    bin.install "airprint_bridge.sh" => "airprint-bridge"
    chmod 0755, bin/"airprint-bridge"
  end

  def caveats
    <<~EOS
      AirPrint Bridge has been installed to #{bin}/airprint-bridge

      To use it:

      1. First, share your printers via System Settings > General > Sharing > Printer Sharing
      2. Test the installation: sudo airprint-bridge -t
      3. Install the service: sudo airprint-bridge -i

      For more information, visit: #{homepage}
    EOS
  end

  test do
    # Test that the script runs and shows usage
    output = shell_output("#{bin}/airprint-bridge -h 2>&1", 1)
    assert_match "Usage:", output
  end
end
