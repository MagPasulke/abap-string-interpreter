import { tool } from "@opencode-ai/plugin"
import { readFileSync } from "node:fs"
import { resolve } from "node:path"
import { adtGitPull } from "../../scripts/adt_gitpull_core"

function loadEnv(dir: string): Record<string, string> {
  const env: Record<string, string> = {}
  try {
    const content = readFileSync(resolve(dir, ".env"), "utf-8")
    for (const line of content.split("\n")) {
      const trimmed = line.trim()
      if (!trimmed || trimmed.startsWith("#")) continue
      const idx = trimmed.indexOf("=")
      if (idx === -1) continue
      const key = trimmed.slice(0, idx).trim()
      const value = trimmed.slice(idx + 1).trim()
      env[key] = value
    }
  } catch {
    // .env not found — fall through to process.env
  }
  return env
}

export default tool({
  description:
    "Triggers an abapGit pull on the SAP system for this repository. " +
    "Automatically finds the repo by matching the git remote URL. " +
    "Uses credentials from .env (SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD). " +
    "If branch is omitted, auto-detects from the current git checkout.",
  args: {
    branch: tool.schema.string()
      .describe(
        "Branch to pull (short name like 'main' or full ref like 'refs/heads/feat/my-feature'). " +
        "If omitted, auto-detects from the currently checked-out branch."
      )
      .optional(),
  },
  async execute(args, context) {
    const rootDir = context.worktree || context.directory
    const env = loadEnv(rootDir)
    const url = process.env.SAP_ADT_URL || env.SAP_ADT_URL
    const user = process.env.SAP_ADT_USER || env.SAP_ADT_USER
    const password = process.env.SAP_ADT_PASSWORD || env.SAP_ADT_PASSWORD

    if (!url || !user || !password) {
      return (
        "ERROR: Missing SAP credentials. Ensure .env contains SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD.\n" +
        `  SAP_ADT_URL: ${url ? "set" : "MISSING"}\n` +
        `  SAP_ADT_USER: ${user ? "set" : "MISSING"}\n` +
        `  SAP_ADT_PASSWORD: ${password ? "set" : "MISSING"}`
      )
    }

    const result = await adtGitPull({
      url,
      user,
      password,
      cwd: rootDir,
      branch: args.branch,
    })

    if (!result.ok) {
      return `ERROR: ${result.error}`
    }

    return (
      `Pull successful.\n` +
      `  Repository: ${result.repoUrl}\n` +
      `  SAP Package: ${result.sapPackage}\n` +
      `  Branch: ${result.branch}\n` +
      `  System: ${result.systemUrl}`
    )
  },
})
