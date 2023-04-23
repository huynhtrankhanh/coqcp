**Call for contributors:** I'm bad at proofs. If you're good with proofs, ping me at https://coq.zulipchat.com and we'll talk.

**You can't bluff a computer.**

This is a repository of formally verified competitive programming code. Formal verification is very important.

https://codeforces.com/blog/entry/111737

The problemsetters of this round accidentally [made an NP-complete problem](https://web.archive.org/web/20230125221257/https://codeforces.com/contest/1780/problem/C), and wrote a wrong greedy solution for it. The testers of this round guessed the same incorrect solution. The mistake was not caught during the review and testing phase. In the actual round, many folks also guessed the same incorrect solution. But a few smart folks proved the problem was NP-complete.

The problemsetters even wrote [an incorrect proof](https://codeforces.com/blog/entry/111737?#comment-996084) for the greedy solution. Community members said the proof doesn't make sense.

This mistake could have been avoided entirely if the folks responsible for the round had used formal verification. I'm learning it. Will you join me?

Dependencies: Only `coq-stdpp`.

Note: Whenever you create a new file, remember to import `Options` with the `From CoqCP Require Import Options.` command. Coq will then error if you apply a tactic when multiple goals are visible.

Documentation:

- [Regular bracket strings](docs/RegularBracketString.md)
- [Selection sort](docs/SelectionSort.md)
- [Repeat and compare](docs/RepeatCompare.md)

Tasks:

- [Sorting subarrays](docs/SortingSubarrays.md)
