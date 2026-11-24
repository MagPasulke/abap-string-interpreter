---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) of this ABAP project along three axes: Standards (AGENTS.md, Clean ABAP, ABAP best practice checked via MCP), Spec (does the code match the originating issue/spec?) and Quality (ponytail-review). Runs the reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Three-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented standards, Clean ABAP and ABAP best practice?
- **Spec**: does the code faithfully implement the originating issue / spec?
- **Quality**: is it correct, safe, tested and lean? Delegated to the `ponytail-review` skill.

All axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings. Start every sub-agent with a fresh context window.

## Project context

This is an **ABAP project** stored in abapGit file format (`.clas.abap`, `.intf.abap`, `.ddls.asddls`, `.bdef.asbdef`, XML metadata, …) without a live SAP connection. Target: **ABAP Cloud / ABAP Platform 2023 (SAP BASIS 758)**, Clean Core. Review ABAP code by **[Clean ABAP](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)** principles and use the MCP servers to check it against ABAP best practice instead of relying on memory:

- `mcp_abap-mcp_abap_feature_matrix`: is every syntax/feature used available on 758?
- `mcp_sap-released-_sap_check_clean_core_compliance`: is every SAP standard object used released for ABAP Cloud? Suggest a successor via `mcp_sap-released-_sap_find_successor` if not.
- `mcp_abap-mcp_sap_community_search` / `mcp_abap-mcp_search`: confirm RAP patterns (behavior definitions, draft, validations, determinations, actions, authorization, feature control) and other non-trivial ABAP idioms against SAP documentation.

`npm run lint` (abaplint, rules in `abaplint.json`) already enforces many style rules; don't report what it catches.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside the parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in the tracker doc.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. `AGENTS.md` is always on the list; when `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list too. Add the relevant project skills the diff touches (e.g. `exception-handling` for exceptions, `create-tests` for tests, `abapgit-*-object` for new repository objects).

**[Clean ABAP](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)** is always a standards source for ABAP code (classes, interfaces, CDS, BDEF): names, methods, classes, error handling, comments, formatting, testing. The repo's own documents override it where they differ.

On top of that, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard or Clean ABAP rule always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn the sub-agents in parallel

Issue all sub-agent calls together, in the foreground, and aggregate the reports they return. Every prompt starts with the **Project context** section above, pasted in full.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, the Clean ABAP link, **plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard or Clean ABAP: cite the standard (file or Clean ABAP section + the rule); (b) every ABAP feature not available on 758 or SAP object not released for ABAP Cloud, verified with the MCP tools; (c) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches, 758 incompatibilities and unreleased objects can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides Clean ABAP and the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

**Quality sub-agent prompt** should include:

- The diff command and commit list.
- The brief: "Call the Skill tool with `ponytail-review` and review this diff with it. Judge ABAP code by Clean ABAP and use the MCP tools from the project context when a finding depends on ABAP or RAP behaviour. Leave standards conformance to the Standards review and spec coverage to the Spec review. Return the ponytail-review report as is."

### 5. Aggregate

Present the three reports under `## Standards`, `## Spec` and `## Quality` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the axes are deliberately separate (see _Why separate axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why separate axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that is clean and on-spec but has a bug, a missing test or dead weight → **Standards and Spec pass, Quality fail.**

Reporting them separately stops one axis from masking another.
