#!/bin/bash
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Load the real option parser and functions without invoking privileged actions.
awk '
    /# Require sudo for install\/uninstall\/test/ { skip=1 }
    /# Function to list local shared printers/ { skip=0 }
    /# Main execution based on COMMAND/ { exit }
    !skip { print }
' "$repo_dir/airprint_bridge.sh" > "$tmp_dir/bridge_functions.sh"

mkdir "$tmp_dir/bin"
cat > "$tmp_dir/bin/dns-sd" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$DNS_SD_ARGS"
EOF
chmod +x "$tmp_dir/bin/dns-sd"
export PATH="$tmp_dir/bin:$PATH"
export DNS_SD_ARGS="$tmp_dir/dns-sd-args"

check_launcher() {
    local launcher="$1"
    [ -x "$launcher" ]
    bash -n "$launcher"
    bash "$launcher"
    grep -Fx 'Brother HL-3180CDW (AirPrint) @ test-host' "$DNS_SD_ARGS"
    grep -Fx 'rp=printers/Brother_Queue' "$DNS_SD_ARGS"
    grep -Fx 'URF=V1.4,MS_A4' "$DNS_SD_ARGS"
}

hostname() { printf 'test-host\n'; }
mock_resolve_printer() {
    printer_desc='Brother HL-3180CDW'
    PORT=631
    TXT_RECORDS=('rp=printers/Brother_Queue' 'URF=V1.4,MS_A4')
}

source "$tmp_dir/bridge_functions.sh" -t -f "$tmp_dir/custom launcher.sh"
resolve_printer() { mock_resolve_printer "$@"; }
PRINTERS=(Brother_Queue)
generate_script
check_launcher "$tmp_dir/custom launcher.sh"

OPTIND=1
source "$tmp_dir/bridge_functions.sh" -t --script_file "$tmp_dir/long-option.sh"
resolve_printer() { mock_resolve_printer "$@"; }
PRINTERS=(Brother_Queue)
generate_script
check_launcher "$tmp_dir/long-option.sh"

echo 'Issue #39 launcher tests passed'
