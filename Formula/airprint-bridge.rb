class AirprintBridge < Formula
  desc "Enable AirPrint functionality for non-AirPrint printers on macOS"
  homepage "https://github.com/sapireli/AirPrint_Bridge"
  url "https://github.com/sapireli/AirPrint_Bridge/archive/59e9440a529e99d3000762608af57b0db6a7b62b.tar.gz"
  version "1.3.2"
  sha256 "889f8f015180dfc86e5b87dde5d55f331ce9fcb11de8a78e739126464321d8f8"
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
