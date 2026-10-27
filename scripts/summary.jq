# Input: {results: [...], passed, requests, quota, fail_on, min_grade}. Output: Markdown for $GITHUB_STEP_SUMMARY.
def cell: tostring | gsub("\\|"; "\\|") | gsub("\n"; " ");
def icon: if . then "✅" else "❌" end;
def sev: {high: "🔴 high", medium: "🟠 medium", low: "🟡 low", info: "⚪ info"}[.] // .;

([.results[] | select(.report)]) as $ok
| ([.results[] | select(.report | not)]) as $other
| "## Shipshape \(.passed | icon)\n",
  "Fail on: `\(.fail_on)`\(if .min_grade != "" then " · minimum grade: `\(.min_grade)`" else "" end)"
  + " · requests used: \(.requests)\(if .quota != "" then " · quota left this month: \(.quota)" else "" end)",
  "",
  (if ($ok | length) > 0 then
    "| File | Grade | Score | High | Medium | Low | Info | Passed |",
    "|---|---|---|---|---|---|---|---|",
    ($ok[] | "| `\(.file | cell)` | \(.report.grade) | \(.report.score) | \(.report.summary.high) | \(.report.summary.medium) | \(.report.summary.low) | \(.report.summary.info) | \(.passed | icon) |"),
    "",
    ($ok[] | select((.report.findings | length) > 0)
      | "<details><summary><code>\(.file)</code>: \(.report.findings | length) findings</summary>",
        "",
        "| Severity | Rule | Line | Finding | Fix |",
        "|---|---|---|---|---|",
        (.report.findings[] | "| \(.severity | sev) | [\(.id)](\(.url // "")) | \(.line // "") | \(.title | cell) | \(.fix // "" | cell) |"),
        "",
        "</details>",
        "")
  else "No Dockerfile or Kubernetes manifest was analysed.\n" end),
  (if ($other | length) > 0 then
    "### Not analysed",
    "",
    "| File | Why |",
    "|---|---|",
    ($other[] | "| `\(.file | cell)` | \(.reason | cell) |"),
    ""
  else empty end)
