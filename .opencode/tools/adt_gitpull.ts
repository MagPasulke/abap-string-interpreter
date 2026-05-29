import { tool } from "@opencode-ai/plugin"
import { adtGitPull } from "./adt_gitpull_core"

export default tool({
  description:
    "Triggers an abapGit pull on the SAP system for this repository. " +
    "Automatically finds the repo by matching the git remote URL. " +
    "No parameters needed — uses credentials from .env (SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD).",
  args: {},
  async execute(_args, context) {
    const url = process.env.SAP_ADT_URL
    const user = process.env.SAP_ADT_USER
    const password = process.env.SAP_ADT_PASSWORD

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
      cwd: context.worktree || context.directory,
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
