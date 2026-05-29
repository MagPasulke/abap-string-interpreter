import { tool } from "@opencode-ai/plugin"
import { ADTClient } from "abap-adt-api"
import { execSync } from "child_process"

export default tool({
  description:
    "Triggers an abapGit pull on the SAP system for this repository. " +
    "Automatically finds the repo by matching the git remote URL. " +
    "No parameters needed — uses credentials from .env (SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD).",
  args: {},
  async execute(_args, context) {
    // 1. Validate credentials
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

    // 2. Determine the git remote URL to match against
    let remoteUrl: string
    try {
      remoteUrl = execSync("git remote get-url origin", {
        cwd: context.worktree || context.directory,
        encoding: "utf-8",
      }).trim()
    } catch {
      return "ERROR: Could not determine git remote URL. Is this a git repository with an 'origin' remote?"
    }

    // Normalize URL for matching (strip .git suffix, trailing slashes)
    const normalizeUrl = (u: string) =>
      u
        .replace(/\.git\/?$/, "")
        .replace(/\/$/, "")
        .toLowerCase()

    const localNormalized = normalizeUrl(remoteUrl)

    // 3. Connect to SAP system
    let client: ADTClient
    try {
      client = new ADTClient(url, user, password)
    } catch (e: any) {
      return `ERROR: Failed to create ADT client: ${e.message || e}`
    }

    // 4. List repos and find matching one
    let repos
    try {
      repos = await client.gitRepos()
    } catch (e: any) {
      return `ERROR: Failed to list abapGit repos on ${url}: ${e.message || e}`
    }

    const matchingRepo = repos.find(
      (repo) => normalizeUrl(repo.url) === localNormalized
    )

    if (!matchingRepo) {
      const available = repos.map((r) => `  - ${r.url} (package: ${r.sapPackage})`).join("\n")
      return (
        `ERROR: No abapGit repo found matching remote URL:\n  ${remoteUrl}\n\n` +
        `Available repos on ${url}:\n${available || "  (none)"}`
      )
    }

    // 5. Trigger pull
    try {
      await client.gitPullRepo(matchingRepo.key)
    } catch (e: any) {
      return (
        `ERROR: Pull failed for repo "${matchingRepo.sapPackage}" (key: ${matchingRepo.key}):\n` +
        `  ${e.message || e}`
      )
    }

    // 6. Success — return details
    return (
      `Pull successful.\n` +
      `  Repository: ${matchingRepo.url}\n` +
      `  SAP Package: ${matchingRepo.sapPackage}\n` +
      `  Branch: ${matchingRepo.branch_name}\n` +
      `  System: ${url}`
    )
  },
})
