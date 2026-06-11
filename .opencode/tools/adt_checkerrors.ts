import { tool } from "@opencode-ai/plugin"
import { readFileSync } from "node:fs"
import { resolve } from "node:path"
import { adtCheckErrors } from "../../scripts/adt_checkerrors_core"

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
    "Checks for syntax errors on the SAP system by detecting inactive objects " +
    "and retrieving their activation error messages. Use after adt_gitpull to " +
    "detect objects that failed activation due to syntax issues. Returns error " +
    "details with object name, line number, and message text.",
  args: {},
  async execute(_args, context) {
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

    const result = await adtCheckErrors({ url, user, password })

    if (!result.ok) {
      return `ERROR: ${result.error}`
    }

    return result.summary
  },
})
