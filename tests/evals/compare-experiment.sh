#!/usr/bin/env bash
# compare-experiment.sh <before.json> <after.json>
#
# Compares two waza run result files using ci95 band overlap per task.
# Produces a verdict table and exits with a code reflecting the outcome.
#
# Prerequisites:
#   - Both result files must be produced with trials_per_task > 1.
#     Use eval-experiment.yaml (trials_per_task: 3), not eval.yaml.
#     With a single trial, ci95 bands are zero and the comparison falls
#     back to a score-only check with a warning.
#
# Exit codes:
#   0  candidate improves (at least one SIGNAL task, no regressions)
#   1  inconclusive (no tasks outside the noise band, no regressions)
#   2  regression detected or script error

set -uo pipefail

# --- Input validation ---

if [[ $# -ne 2 ]]; then
  echo "Usage: compare-experiment.sh <before.json> <after.json>" >&2
  exit 2
fi

before="$1"
after="$2"

if [[ ! -f "$before" ]]; then
  echo "Error: file not found: $before" >&2
  exit 2
fi

if [[ ! -f "$after" ]]; then
  echo "Error: file not found: $after" >&2
  exit 2
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required" >&2
  exit 2
fi

# --- ci95 availability check ---

has_ci_b=$(jq -r '[.tasks[].stats.ci95_hi // 0] | any(. > 0)' "$before")
has_ci_a=$(jq -r '[.tasks[].stats.ci95_hi // 0] | any(. > 0)' "$after")

if [[ "$has_ci_b" == "true" && "$has_ci_a" == "true" ]]; then
  has_ci="true"
else
  has_ci="false"
  echo "Warning: ci95 bands are missing from one or both result files." >&2
  echo "         Run both baseline and candidate with eval-experiment.yaml" >&2
  echo "         (trials_per_task: 3) for variance-aware results." >&2
  echo "         Falling back to score-only comparison." >&2
  echo ""
fi

# --- Join tasks and compute per-task verdicts ---

comparison=$(jq -n \
  --slurpfile b "$before" \
  --slurpfile a "$after" \
  --argjson has_ci "$has_ci" \
  '
  ($b[0]) as $b | ($a[0]) as $a |

  ($a.tasks | map({key: .test_id, value: .}) | from_entries) as $after_map |

  ($b.summary.aggregate_score // 0) as $b_agg |
  ($a.summary.aggregate_score // 0) as $a_agg |

  {
    aggregate: {
      before: $b_agg,
      after:  $a_agg,
      delta:  ($a_agg - $b_agg)
    },
    has_ci: $has_ci,
    tasks: [
      $b.tasks[] |
      . as $bt |
      ($after_map[.test_id] // null) as $at |
      if $at == null then empty
      else
        ($bt.stats.avg_score // 0) as $b_avg |
        ($bt.stats.ci95_lo   // 0) as $b_lo  |
        ($bt.stats.ci95_hi   // 0) as $b_hi  |
        ($at.stats.avg_score // 0) as $a_avg |
        ($at.stats.ci95_lo   // 0) as $a_lo  |
        ($at.stats.ci95_hi   // 0) as $a_hi  |

        # Variance-aware verdict when ci95 bands are populated.
        # Per-task guard: fall back to score-only when per-task bands are zero
        # (e.g. a partial run), even when has_ci is true globally.
        (if ($has_ci and $b_hi > 0 and $a_hi > 0) then
          if   $a_lo > $b_hi then "SIGNAL"
          elif $a_hi < $b_lo then "REGRESSION"
          elif $b_avg == $a_avg then "NO_CHANGE"
          else "INCONCLUSIVE"
          end
        else
          if   $a_avg > $b_avg then "SIGNAL"
          elif $a_avg < $b_avg then "REGRESSION"
          else "NO_CHANGE"
          end
        end) as $verdict |

        {
          test_id:      $bt.test_id,
          display_name: ($bt.display_name // $bt.test_id),
          before_avg:   $b_avg,
          after_avg:    $a_avg,
          delta:        ($a_avg - $b_avg),
          verdict:      $verdict
        }
      end
    ]
  }
  ')

# --- Output ---

echo ""
echo "Experiment Comparison"
echo "====================="
printf "Baseline:   %s\n" "$before"
printf "Candidate:  %s\n" "$after"
echo ""

b_agg=$(echo "$comparison" | jq -r '.aggregate.before')
a_agg=$(echo "$comparison" | jq -r '.aggregate.after')
delta=$(echo "$comparison" | jq -r '.aggregate.delta')
printf "Aggregate:  %.2f → %.2f  (%+.2f)\n" "$b_agg" "$a_agg" "$delta"
echo ""
echo "Per-task:"

signal_count=0
regression_count=0

while IFS=$'\t' read -r display b_avg a_avg verdict; do
  display="${display:0:35}"

  case "$verdict" in
    SIGNAL)       label="SIGNAL"       ; signal_count=$((signal_count + 1)) ;;
    REGRESSION)   label="REGRESSION"   ; regression_count=$((regression_count + 1)) ;;
    NO_CHANGE)    label="NO CHANGE"    ;;
    INCONCLUSIVE) label="INCONCLUSIVE" ;;
    *)            label="$verdict"     ;;
  esac

  printf "  %-35s %.2f → %.2f   %s\n" "$display" "$b_avg" "$a_avg" "$label"
done < <(echo "$comparison" | jq -r '.tasks[] | [.display_name, .before_avg, .after_avg, .verdict] | @tsv')

echo ""

# --- Verdict and exit ---

if [[ "$has_ci" == "false" ]]; then
  echo "Note: score-only comparison (no ci95 bands). Results may reflect LLM variance."
  echo "      Rerun with eval-experiment.yaml for a variance-aware verdict."
  echo ""
fi

if [[ $regression_count -gt 0 ]]; then
  echo "Verdict: REGRESSION DETECTED — ${regression_count} task(s) regressed"
  exit 2
elif [[ $signal_count -gt 0 ]]; then
  echo "Verdict: CANDIDATE IMPROVES — ${signal_count} task(s) show real signal, 0 regressions"
  exit 0
else
  echo "Verdict: INCONCLUSIVE — no tasks outside the noise band"
  exit 1
fi
