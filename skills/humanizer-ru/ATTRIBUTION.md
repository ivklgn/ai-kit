# Attribution

The **`humanizer-ru`** skill is a port of [ilyautov/humanizer-ru](https://github.com/ilyautov/humanizer-ru) by **Ilya Utov** ([@ilyautov](https://github.com/ilyautov)), distributed under the MIT License.

The port includes the skill body (v3.12) and the metric scripts (`scripts/scan.py`, `scripts/humanizer_metrics/`) used for scoring AI markers in Russian text.

Changes in the ai-kit port:

- Added the `model` field to the frontmatter per ai-kit plugin conventions
- Body and scripts content unchanged

This skill works ONLY with Russian text. For English, use the companion `humanizer` skill (port of blader/humanizer).

Full license text: see [`THIRD-PARTY-LICENSES.md`](../../THIRD-PARTY-LICENSES.md) at the repository root.
