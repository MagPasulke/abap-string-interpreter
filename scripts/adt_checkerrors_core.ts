import { ADTClient, InactiveObjectRecord, ActivationResult } from "abap-adt-api"

export interface AdtCheckErrorsOptions {
  /** SAP system base URL (e.g. https://host:44300) */
  url: string
  /** SAP user */
  user: string
  /** SAP password */
  password: string
}

export interface ActivationError {
  /** Object description (e.g. "Class ZASIS_CL_INTERPRETER") */
  object: string
  /** Error severity (E=Error, W=Warning, A=Abort) */
  type: string
  /** Line number where error occurs */
  line: number
  /** Error message text */
  message: string
  /** ADT URI of the object */
  href: string
}

export interface AdtCheckErrorsSuccess {
  ok: true
  /** Number of inactive objects found */
  inactiveCount: number
  /** Activation error messages (empty if all objects activated successfully) */
  errors: ActivationError[]
  /** Human-readable summary */
  summary: string
}

export interface AdtCheckErrorsError {
  ok: false
  error: string
}

export type AdtCheckErrorsResult = AdtCheckErrorsSuccess | AdtCheckErrorsError

/**
 * Checks for inactive objects on a SAP system and retrieves their
 * activation/syntax error messages by attempting preaudit activation.
 *
 * Objects that have no errors will be activated (which is the desired state).
 * Objects with syntax errors remain inactive and their error messages are returned.
 */
export async function adtCheckErrors(options: AdtCheckErrorsOptions): Promise<AdtCheckErrorsResult> {
  const { url, user, password } = options

  // 1. Connect to SAP system
  let client: ADTClient
  try {
    client = new ADTClient(url, user, password)
  } catch (e: any) {
    return { ok: false, error: `Failed to create ADT client: ${e.message || e}` }
  }

  // 2. Get inactive objects
  let inactiveRecords: InactiveObjectRecord[]
  try {
    inactiveRecords = await client.inactiveObjects()
  } catch (e: any) {
    return { ok: false, error: `Failed to retrieve inactive objects: ${e.message || e}` }
  }

  // Filter to records that have an actual object (not just transport entries)
  const inactiveObjects = inactiveRecords
    .filter((r) => r.object)
    .map((r) => r.object!)

  if (inactiveObjects.length === 0) {
    return {
      ok: true,
      inactiveCount: 0,
      errors: [],
      summary: "No inactive objects found. All objects are active and syntax-error-free.",
    }
  }

  // 3. Attempt activation with preaudit to get error messages
  let activationResult: ActivationResult
  try {
    activationResult = await client.activate(
      inactiveObjects.map((obj) => ({
        "adtcore:uri": obj["adtcore:uri"],
        "adtcore:type": obj["adtcore:type"],
        "adtcore:name": obj["adtcore:name"],
        "adtcore:parentUri": obj["adtcore:parentUri"] || "",
      })),
      true // preauditRequested
    )
  } catch (e: any) {
    // If activation call itself fails, still report the inactive objects
    const objectList = inactiveObjects
      .map((o) => `  - ${o["adtcore:name"]} (${o["adtcore:type"]})`)
      .join("\n")
    return {
      ok: false,
      error:
        `Found ${inactiveObjects.length} inactive object(s) but activation preaudit failed: ${e.message || e}\n\n` +
        `Inactive objects:\n${objectList}`,
    }
  }

  // 4. Extract error messages
  const errors: ActivationError[] = activationResult.messages.map((msg) => ({
    object: msg.objDescr,
    type: msg.type,
    line: msg.line,
    message: msg.shortText,
    href: msg.href,
  }))

  // 5. Format summary
  const summary = formatSummary(inactiveObjects.length, activationResult, errors)

  return {
    ok: true,
    inactiveCount: inactiveObjects.length,
    errors,
    summary,
  }
}

function formatSummary(
  inactiveCount: number,
  result: ActivationResult,
  errors: ActivationError[]
): string {
  const lines: string[] = []

  if (result.success && errors.length === 0) {
    lines.push(`All ${inactiveCount} inactive object(s) activated successfully. No syntax errors.`)
    return lines.join("\n")
  }

  const errorCount = errors.filter((e) => e.type === "E" || e.type === "A").length
  const warningCount = errors.filter((e) => e.type === "W").length
  const stillInactive = result.inactive?.length ?? 0

  lines.push(`SYNTAX ERRORS FOUND: ${errorCount} error(s), ${warningCount} warning(s)`)
  lines.push(`  Inactive objects checked: ${inactiveCount}`)
  if (stillInactive > 0) {
    lines.push(`  Still inactive after attempt: ${stillInactive}`)
  }
  lines.push("")

  for (const err of errors) {
    const severity = err.type === "E" ? "ERROR" : err.type === "W" ? "WARN" : err.type
    const lineInfo = err.line > 0 ? `:${err.line}` : ""
    lines.push(`  [${severity}] ${err.object}${lineInfo}`)
    lines.push(`         ${err.message}`)
  }

  return lines.join("\n")
}
