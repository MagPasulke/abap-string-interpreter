/**
 * CI/CLI runner: checks for syntax errors (inactive objects) on the SAP system.
 *
 * Reads SAP credentials from environment variables:
 *   SAP_ADT_URL      – base URL of the SAP system (e.g. https://host:44300)
 *   SAP_ADT_USER     – SAP user
 *   SAP_ADT_PASSWORD – SAP password
 *
 * Usage:
 *   npx tsx scripts/adt-checkerrors-ci.ts
 */

import { adtCheckErrors } from "./adt_checkerrors_core.ts"

const url = process.env.SAP_ADT_URL
const user = process.env.SAP_ADT_USER
const password = process.env.SAP_ADT_PASSWORD

if (!url || !user || !password) {
  console.error("Missing required env vars: SAP_ADT_URL, SAP_ADT_USER, SAP_ADT_PASSWORD")
  process.exit(1)
}

void (async () => {
  const result = await adtCheckErrors({ url, user, password })

  if (!result.ok) {
    console.error("Error check failed:", result.error)
    process.exit(1)
  }

  console.log(result.summary)

  // Exit with non-zero if errors were found
  if (result.errors.some((e) => e.type === "E" || e.type === "A")) {
    process.exit(1)
  }
})()
