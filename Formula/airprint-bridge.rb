class AirprintBridge < Formula
  desc "Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS"
  homepage "https://github.com/sapireli/AirPrint_Bridge"
  url "https://github.com/sapireli/AirPrint_Bridge/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256" # This will need to be calculated after the release
  license "MIT"
  head "https://github.com/sapireli/AirPrint_Bridge.git", branch: "main"

  depends_on :macos

  def install
    # Install the main script
    bin.install "airprint_bridge.sh" => "airprint-bridge"
    
    # Install documentation
    doc.install Dir["docs/*"]
    doc.install "README.md"
    
    # Install license
    prefix.install "LICENSE"
  end

  def caveats
    <<~EOS
      AirPrint Bridge has been installed successfully!
      
      To get started:
      1. Enable printer sharing in System Settings > General > Sharing
      2. Test the installation: sudo airprint-bridge -t
      3. Install the service: sudo airprint-bridge -i
      
      For more information, visit: https://sapireli.github.io/AirPrint_Bridge/
      
      Documentation is available in: #{doc}
    EOS
  end

  test do
    # Test that the script exists and is executable
    assert_predicate bin/"airprint-bridge", :exist?
    assert_predicate bin/"airprint-bridge", :executable?
    
    # Test help output
    output = shell_output("#{bin}/airprint-bridge --help", 1)
    assert_match "AirPrint Bridge", output
  end
end 