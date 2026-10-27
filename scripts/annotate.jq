# Input: array of {file, report}. Output: workflow-command lines, high severity first.
# GitHub shows at most 10 error and 10 warning annotations per step: the rest is in the job summary.
def esc_data: gsub("%"; "%25") | gsub("\r"; "%0D") | gsub("\n"; "%0A");
def esc_prop: esc_data | gsub(":"; "%3A") | gsub(","; "%2C");
def level: {high: "error", medium: "warning", low: "notice", info: "notice"}[.severity] // "notice";
def rank: {high: 0, medium: 1, low: 2, info: 3}[.severity] // 4;

[ .[] | .file as $f | .report.findings[]? | . + {file: $f} ]
| sort_by(rank)
| group_by(level)
| map(.[:10])
| flatten
| sort_by(rank)
| .[]
| "::\(level) file=\(.file | esc_prop)\(if .line then ",line=\(.line)" else "" end),title=\("\(.id) \(.title)" | esc_prop)::"
  + ("\(.detail // "")\(if .fix then "\nFix: \(.fix)" else "" end)" | esc_data)
