/**
 * CI runner: triggers an abapGit pull on the SAP system.
 *
 * Reads SAP credentials from environment variables:
 *   SAP_ADT_URL      – base URL of the SAP system (e.g. https://host:44300)
 *   SAP_ADT_USER     – SAP user
 *   SAP_ADT_PASSWORD – SAP password
 *
 * Usage:
 *   npx tsx scripts/adt-gitpull-ci.ts
 */

import { adtGitPull } from "./adt_gitpull_core.ts"

const url = process.env.SAP_ADT_URL
const user = process.env.SAP_ADT_USER
const password = process.env.SAP_ADT_PASSWORD

if (!url || !user || !password) {
  console.error("Missing required env vars: SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD")
  process.exit(1)
}

void (async () => {
  const result = await adtGitPull({ url, user, password, cwd: process.cwd() })

  if (!result.ok) {
    console.error("abapGit pull failed:", result.error)
    process.exit(1)
  }

  console.log(`abapGit pull succeeded`)
  console.log(`  Repo:    ${result.repoUrl}`)
  console.log(`  Package: ${result.sapPackage}`)
  console.log(`  Branch:  ${result.branch}`)
  console.log(`  System:  ${result.systemUrl}`)
})()
