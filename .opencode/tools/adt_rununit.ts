import { tool } from "@opencode-ai/plugin"
import { readFileSync } from "node:fs"
import { resolve } from "node:path"
import { adtRunUnit } from "../../scripts/adt_rununit_core"

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
    "Runs ABAP Unit tests on the remote SAP system via ADT. " +
    "Optional parameters: objectType (CLAS or DEVC) and objectName. " +
    "If omitted, runs tests for the package defined in SAP_ROOT_PACKAGE (.env). " +
    "Returns a formatted summary with pass/fail counts and failure details.",
  args: {
    objectType: tool.schema.string()
      .describe(
        "ABAP object type: 'CLAS' (class) or 'DEVC' (package). " +
        "Defaults to DEVC (package) when objectName is omitted."
      )
      .optional(),
    objectName: tool.schema.string()
      .describe(
        "ABAP object name (e.g. 'ZASIS_CL_INTERPRETER' for a class, or 'ZASIS' for a package). " +
        "If omitted, uses SAP_ROOT_PACKAGE from .env."
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

    // Resolve object type and name
    let objectType: "CLAS" | "DEVC"
    let objectName: string

    if (args.objectName) {
      objectType = (args.objectType === "CLAS") ? "CLAS" : "DEVC"
      objectName = args.objectName
    } else {
      // No object specified — use root package
      const rootPackage = process.env.SAP_ROOT_PACKAGE || env.SAP_ROOT_PACKAGE
      if (!rootPackage) {
        return (
          "ERROR: No target specified and SAP_ROOT_PACKAGE is not configured.\n" +
          "Either pass objectType + objectName, or set SAP_ROOT_PACKAGE in .env."
        )
      }
      objectType = "DEVC"
      objectName = rootPackage
    }

    const result = await adtRunUnit({
      url,
      user,
      password,
      objectType,
      objectName,
    })

    if (!result.ok) {
      return `ERROR: ${result.error}`
    }

    return result.summary
  },
})
