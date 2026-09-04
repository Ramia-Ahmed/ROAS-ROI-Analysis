# ROAS & ROI Analysis — Marketing Channel Efficiency

## Overview

This project analyzes marketing return on ad spend (ROAS) and return on investment (ROI) across six marketing channels over a full year (2024), using a synthetic dataset built specifically for this analysis. The goal was to answer a set of questions a marketing/growth stakeholder would realistically ask: is spend profitable overall, which channels are efficient, is the inefficiency isolated to specific campaigns, does spending more erode efficiency, and — if a channel underperforms — is that a funnel problem or a cost problem.

**Tools used:** DuckDB (SQL), Python (dataset generation), Power BI (dashboard)

## Dataset

The dataset is **fully synthetic**, generated in Python and not derived from any real company's data. It simulates weekly campaign-level marketing performance across 6 channels (Paid Search, Paid Social, Display, Email, Affiliate, Organic/SEO) and 14 campaigns, for all 52 weeks of 2024 (742 rows).

Each channel was built with a distinct, intentional performance profile (base ROAS target, cost-per-click range, and spend range) so the dataset would contain realistic, discoverable patterns rather than pure noise — for example, Organic/SEO and Email were designed as low-cost/high-efficiency channels, and Display as a high-cost/low-efficiency one. A seasonal spend increase was also built into November and December to simulate a holiday campaign push.

**Columns:** `week_start_date`, `channel`, `campaign`, `impressions`, `clicks`, `conversions`, `spend`, `revenue`, `roas`, `roi_pct`

**Core metrics:**
- ROAS = `SUM(revenue) / SUM(spend)`
- ROI % = `(SUM(revenue) − SUM(spend)) / SUM(spend) × 100`
- CAC = `SUM(spend) / SUM(conversions)`

All ratio metrics were calculated as blended aggregates (sum of revenue over sum of spend), not as an average of per-row ratios, to avoid overweighting low-spend rows.

## Key Findings

**1. Overall spend is profitable.** Blended ROAS across all channels and the full year is **2.89x**, with a blended ROI of **189%** — every $1 spent returned $2.89 in revenue. Blended CAC is $21.63 per conversion.

**2. Efficiency varies sharply by channel.** Organic/SEO (6.33x) and Email (5.43x) are the most efficient channels; Display (1.35x) is the weakest, with Paid Social (2.40x) also lagging. Comparing each channel's share of total spend against its share of total revenue shows Display and Paid Social together consume ~44% of budget but return only ~32% of revenue — a gap that represents a plausible budget reallocation opportunity.

**3. The gap is channel-wide, not campaign-specific.** Breaking Display and Paid Social down by individual campaign shows near-identical ROAS across every campaign within each channel. This rules out "one bad campaign" as the explanation — the weakness is structural to the channel itself, not fixable by cutting a single underperforming campaign.

**4. Spend level does not explain the gap (no diminishing returns).** Blended ROAS stays in a tight 2.67–3.00 band across all 12 months with no clear trend. At the weekly level within Paid Social and Display individually, the correlation between spend and ROAS is essentially zero (r ≈ −0.05 for both). Even the highest-spend weeks of the year (November/December) show no consistent efficiency drop. Efficiency differences are between channels, not driven by how much is spent within a channel.

**5. The real driver is acquisition cost, not funnel quality.** Click-through rate (1.5–1.83%) and conversion rate (4.15–4.7%) are nearly identical across all six channels — Display's funnel converts about as well as Paid Search's. What differs dramatically is cost per conversion (CAC): $3.41 for Organic/SEO vs. $26–32 for every paid channel, with Display highest at $32.13. The ROAS gap is a cost-efficiency story, not an audience-quality or creative-quality story.

## Recommendation

Based on the findings above, the most defensible recommendation is a **partial budget reallocation from Display (and to a lesser extent Paid Social) toward Organic/SEO, Email, and Paid Search**, since the latter three convert spend into revenue substantially more efficiently and the underperformance is structural rather than tied to a single fixable campaign or a spend-scaling issue.

One caveat worth stating for a real-world stakeholder: Display advertising is often used for upper-funnel brand awareness rather than direct response, so a pure ROAS-based cut should be weighed against its non-revenue objectives — a limitation not present in this dataset since it only models direct conversion behavior.

## Limitations

- All spend, revenue, and funnel figures are synthetic and were generated with built-in assumptions (see Dataset section) — they do not reflect any real business's actual marketing performance.
- The dataset models only direct-response conversion; it does not capture brand-awareness value, cross-channel attribution effects, or multi-touch customer journeys.
- Random noise was added at generation time, so exact figures will differ slightly if the dataset is regenerated with a different seed; the channel-level patterns and rankings are the intended, reproducible signal.
