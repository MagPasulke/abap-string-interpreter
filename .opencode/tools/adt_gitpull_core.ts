import { ADTClient, GitRepo } from "abap-adt-api"
import { execSync } from "node:child_process"

export interface AdtGitPullOptions {
  /** SAP system base URL (e.g. https://host:44300) */
  url: string
  /** SAP user */
  user: string
  /** SAP password */
  password: string
  /** Working directory to resolve git remote from */
  cwd: string
}

export interface AdtGitPullSuccess {
  ok: true
  repoUrl: string
  sapPackage: string
  branch: string
  systemUrl: string
}

export interface AdtGitPullError {
  ok: false
  error: string
}

export type AdtGitPullResult = AdtGitPullSuccess | AdtGitPullError

/** Normalize git URL for comparison (strip .git suffix, trailing slashes, lowercase) */
function normalizeUrl(u: string): string {
  return u
    .replace(/\.git\/?$/, "")
    .replace(/\/$/, "")
    .toLowerCase()
}

/**
 * Triggers an abapGit pull on a SAP system for the repository matching
 * the local git remote URL.
 */
export async function adtGitPull(options: AdtGitPullOptions): Promise<AdtGitPullResult> {
  const { url, user, password, cwd } = options

  // 1. Determine the git remote URL to match against
  let remoteUrl: string
  try {
    remoteUrl = execSync("git remote get-url origin", {
      cwd,
      encoding: "utf-8",
    }).trim()
  } catch {
    return {
      ok: false,
      error: "Could not determine git remote URL. Is this a git repository with an 'origin' remote?",
    }
  }

  const localNormalized = normalizeUrl(remoteUrl)

  // 2. Connect to SAP system
  let client: ADTClient
  try {
    client = new ADTClient(url, user, password)
  } catch (e: any) {
    return { ok: false, error: `Failed to create ADT client: ${e.message || e}` }
  }

  // 3. List repos and find matching one
  let repos: GitRepo[]
  try {
    repos = await client.gitRepos()
  } catch (e: any) {
    return { ok: false, error: `Failed to list abapGit repos on ${url}: ${e.message || e}` }
  }

  const matchingRepo = repos.find(
    (repo) => normalizeUrl(repo.url) === localNormalized
  )

  if (!matchingRepo) {
    const available = repos.map((r) => `  - ${r.url} (package: ${r.sapPackage})`).join("\n")
    return {
      ok: false,
      error:
        `No abapGit repo found matching remote URL:\n  ${remoteUrl}\n\n` +
        `Available repos on ${url}:\n${available || "  (none)"}`,
    }
  }

  // 4. Trigger pull
  try {
    await client.gitPullRepo(matchingRepo.key)
  } catch (e: any) {
    return {
      ok: false,
      error: `Pull failed for repo "${matchingRepo.sapPackage}" (key: ${matchingRepo.key}): ${e.message || e}`,
    }
  }

  // 5. Success
  return {
    ok: true,
    repoUrl: matchingRepo.url,
    sapPackage: matchingRepo.sapPackage,
    branch: matchingRepo.branch_name,
    systemUrl: url,
  }
}
