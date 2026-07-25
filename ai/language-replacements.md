Do not use metaphors or LLM-speak such as "load-bearing", "the honest truth", "sharp", or any
language that has that flavor; just write in a sober, straightforward, direct way without any extra
verbosity or editorialization.

// TestExponentialBackoffOverflow verifies overflow handling when
// initInterval * coefficient^(attempt-1) exceeds the largest duration an int64 can represent.
// The float64->int64 conversion of an out-of-range value is implementation-defined in Go (amd64
// yields math.MinInt64, arm64 saturates), so the guard must clamp in float space before conversion.
func TestExponentialBackoffOverflow(t *testing.T) {
	t.Run("Algorithm saturates to max duration", func(t *testing.T) {
		// 1s * 2^99 vastly exceeds MaxInt64 nanoseconds.
		interval := ExponentialBackoffAlgorithm(durationpb.New(time.Second), 2.0, 100)
		require.Equal(t, time.Duration(math.MaxInt64), interval)
	})

	// A broken overflow guard that returns 0 escapes the `interval > maxInterval` cap check and
	// collapses the retry backoff to zero (rapid-fire retries).
	t.Run("Interval still capped to MaximumInterval", func(t *testing.T) {
		interval := CalculateExponentialRetryInterval(&commonpb.RetryPolicy{
			InitialInterval:    durationpb.New(time.Second),
			BackoffCoefficient: 2.0,
			MaximumInterval:    durationpb.New(100 * time.Second),
		}, 100)
		require.Equal(t, 100*time.Second, interval)
	})




  I also rewrote the metaphor offenders I found in the incumbent: "irreducible floor," "the crux," "wart," "escape hatch," "where the amortization lands," "burns no retries," "rides on the item," and the heading
  "two drivers" (→ "Admission", since there are three plus generative).

"load-bearing, not hygiene" → "essential, not optional"
"forcing-function consumer" → "the consumer that justifies prioritizing"
"engineering margin under two same-sized bounds" →  the plain arithmetic
"knob turn" → "the segment-size setting goes up."


> every dirty flush window rewrites the whole   segment document

Is this saying "when WAL content is flushed to Cassandra it contains and replaces the entire executions table row contents"?

> **per-item reads** (`ListUnits`, `DescribeItem`) have no sub-tree read primitive today

Is this saying "The only way to read an item is to read the entire CHAM tree"?

> Live set per segment ~10⁴ rows (~150 B each) —  an engineering margin under two same-sized bounds, the ~5 MB MS-size discipline and  per-transaction deserialize cost.

Is this saying "I estimate that each segment may be able to hold ~10^4 items. This is because there
are two different constraints imposing similar bounds: (1) MS size is limited to 5 MB, and (2)
deserialization of data <something something>" [can you finish this off in the style I'm using? what
is B, and what's the connection between 5 MB and 10^4 and 150?]
