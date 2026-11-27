import { Plugin } from "@opencode/plugin"
import { readFileSync } from "node:fs"
import { resolve } from "node:path"
import { adtGitPull } from "../../../scripts/adt_gitpull_core"
import { adtRunUnit } from "../../../scripts/adt_rununit_core"
import { adtCheckErrors } from "../../../scripts/adt_checkerrors_core"

interface AdtConfig {
  url?: string
  user?: string
  password?: string
  caFile?: string
  rootPackage?: string
}

function loadEnv(dir: string): Record<string, string> {
  const env: Record<string, string> = {}
  try {
    const content = readFileSync(resolve(dir, ".env"), "utf-8")
    for (const line of content.split("\n")) {
      const trimmed = line.trim()
      if (!trimmed || trimmed.startsWith("#")) continue
      const idx = trimmed.indexOf("=")
      if (idx === -1) continue
      env[trimmed.slice(0, idx).trim()] = trimmed.slice(idx + 1).trim()
    }
  } catch {
    // .env not found — fall through to process.env
  }
  return env
}

function loadConfig(dir: string): AdtConfig {
  const env = loadEnv(dir)
  return {
    url: process.env.SAP_ADT_URL || env.SAP_ADT_URL,
    user: process.env.SAP_ADT_USER || env.SAP_ADT_USER,
    password: process.env.SAP_ADT_PASSWORD || env.SAP_ADT_PASSWORD,
    caFile: process.env.SAP_ADT_CA_FILE || env.SAP_ADT_CA_FILE,
    rootPackage: process.env.SAP_ROOT_PACKAGE || env.SAP_ROOT_PACKAGE,
  }
}

function missingCredentials(cfg: AdtConfig): string | undefined {
  if (cfg.url && cfg.user && cfg.password) return undefined
  return (
    "ERROR: Missing SAP credentials. Ensure .env contains SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD.\n" +
    `  SAP_ADT_URL: ${cfg.url ? "set" : "MISSING"}\n` +
    `  SAP_ADT_USER: ${cfg.user ? "set" : "MISSING"}\n` +
    `  SAP_ADT_PASSWORD: ${cfg.password ? "set" : "MISSING"}`
  )
}

export default Plugin.define({
  id: "zasis.adt",
  async setup(ctx) {
    const rootDir: string = ctx.location.directory

    await ctx.tool.transform((editor) => {
      editor.add({
        name: "adt_gitpull",
        description:
          "Triggers an abapGit pull on the SAP system for this repository. " +
          "Automatically finds the repo by matching the git remote URL. " +
          "Uses credentials from .env (SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD). " +
          "If branch is omitted, auto-detects from the current git checkout. " +
          "Set checkErrors=true to detect syntax errors (inactive objects) after pull.",
        input: {
          type: "object",
          properties: {
            branch: {
              type: "string",
              description:
                "Branch to pull (short name like 'main' or full ref like 'refs/heads/feat/my-feature'). " +
                "If omitted, auto-detects from the currently checked-out branch.",
            },
            checkErrors: {
              type: "boolean",
              description:
                "If true, checks for inactive objects (syntax errors) after pull and reports details. Default: false.",
            },
          },
          additionalProperties: false,
        },
        async execute(input) {
          const args = input as { branch?: string; checkErrors?: boolean }
          const cfg = loadConfig(rootDir)
          const missing = missingCredentials(cfg)
          if (missing) return { content: missing }

          const result = await adtGitPull({
            url: cfg.url!,
            user: cfg.user!,
            password: cfg.password!,
            cwd: rootDir,
            branch: args.branch,
            checkErrors: args.checkErrors,
            caFile: cfg.caFile,
          })
          if (!result.ok) return { content: `ERROR: ${result.error}` }

          let output =
            `Pull successful.\n` +
            `  Repository: ${result.repoUrl}\n` +
            `  SAP Package: ${result.sapPackage}\n` +
            `  Branch: ${result.branch}\n` +
            `  System: ${result.systemUrl}`

          if (result.checkResult) {
            output += `\n\n--- Error Check ---\n`
            output += result.checkResult.ok ? result.checkResult.summary : `ERROR: ${result.checkResult.error}`
          }
          return { content: output }
        },
      })

      editor.add({
        name: "adt_rununit",
        description:
          "Runs ABAP Unit tests on the remote SAP system via ADT. " +
          "Optional parameters: objectType (CLAS or DEVC) and objectName. " +
          "If omitted, runs tests for the package defined in SAP_ROOT_PACKAGE (.env). " +
          "Returns a formatted summary with pass/fail counts and failure details.",
        input: {
          type: "object",
          properties: {
            objectType: {
              type: "string",
              description:
                "ABAP object type: 'CLAS' (class) or 'DEVC' (package). " +
                "Defaults to DEVC (package) when objectName is omitted.",
            },
            objectName: {
              type: "string",
              description:
                "ABAP object name (e.g. 'ZASIS_CL_INTERPRETER' for a class, or 'ZASIS' for a package). " +
                "If omitted, uses SAP_ROOT_PACKAGE from .env.",
            },
          },
          additionalProperties: false,
        },
        async execute(input) {
          const args = input as { objectType?: string; objectName?: string }
          const cfg = loadConfig(rootDir)
          const missing = missingCredentials(cfg)
          if (missing) return { content: missing }

          let objectType: "CLAS" | "DEVC"
          let objectName: string
          if (args.objectName) {
            objectType = args.objectType === "CLAS" ? "CLAS" : "DEVC"
            objectName = args.objectName
          } else {
            if (!cfg.rootPackage) {
              return {
                content:
                  "ERROR: No target specified and SAP_ROOT_PACKAGE is not configured.\n" +
                  "Either pass objectType + objectName, or set SAP_ROOT_PACKAGE in .env.",
              }
            }
            objectType = "DEVC"
            objectName = cfg.rootPackage
          }

          const result = await adtRunUnit({
            url: cfg.url!,
            user: cfg.user!,
            password: cfg.password!,
            objectType,
            objectName,
            caFile: cfg.caFile,
          })
          return { content: result.ok ? result.summary : `ERROR: ${result.error}` }
        },
      })

      editor.add({
        name: "adt_checkerrors",
        description:
          "Checks for syntax errors on the SAP system by running ATC with the SYNTAX_CHECK " +
          "variant on the project package. Use after adt_gitpull to detect objects with " +
          "syntax issues. Returns error details with object name, line number, and message text.",
        input: { type: "object", properties: {}, additionalProperties: false },
        async execute() {
          const cfg = loadConfig(rootDir)
          const missing = missingCredentials(cfg)
          if (missing) return { content: missing }

          const result = await adtCheckErrors({
            url: cfg.url!,
            user: cfg.user!,
            password: cfg.password!,
            package: cfg.rootPackage,
            caFile: cfg.caFile,
          })
          return { content: result.ok ? result.summary : `ERROR: ${result.error}` }
        },
      })
    })
  },
})
