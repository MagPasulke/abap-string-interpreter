import { ADTClient, AtcWorkList } from "abap-adt-api"

export interface AdtCheckErrorsOptions {
  /** SAP system base URL (e.g. https://host:44300) */
  url: string
  /** SAP user */
  user: string
  /** SAP password */
  password: string
  /** SAP package to check (e.g. "$ZASIS"). Uses SAP_ROOT_PACKAGE from env if omitted. */
  package?: string
}

export interface SyntaxFinding {
  /** Object name (e.g. "ZASIS_CL_INTERPRETER") */
  object: string
  /** Object type (e.g. "CLAS") */
  objectType: string
  /** Priority: 1=error, 2=warning, 3=info */
  priority: number
  /** Check that produced the finding */
  checkTitle: string
  /** Finding message text */
  message: string
  /** Location line number */
  line: number
  /** Location column */
  column: number
}

export interface AdtCheckErrorsSuccess {
  ok: true
  /** Total objects checked */
  objectsChecked: number
  /** Number of findings (errors + warnings) */
  findingCount: number
  /** Structured findings */
  findings: SyntaxFinding[]
  /** Human-readable summary */
  summary: string
}

export interface AdtCheckErrorsError {
  ok: false
  error: string
}

export type AdtCheckErrorsResult = AdtCheckErrorsSuccess | AdtCheckErrorsError

/**
 * Runs a syntax check on a SAP package using the ATC (ABAP Test Cockpit)
 * with the SYNTAX_CHECK variant. Returns all syntax errors and warnings
 * found in the package.
 */
export async function adtCheckErrors(options: AdtCheckErrorsOptions): Promise<AdtCheckErrorsResult> {
  const { url, user, password } = options
  const pkg = options.package || "$ZASIS"

  // 1. Connect to SAP system
  let client: ADTClient
  try {
    client = new ADTClient(url, user, password)
  } catch (e: any) {
    return { ok: false, error: `Failed to create ADT client: ${e.message || e}` }
  }

  // 2. Run ATC with SYNTAX_CHECK variant on the package
  const packageUrl = `/sap/bc/adt/packages/${encodeURIComponent(pkg.toLowerCase())}`
  let runResult: { id: string; timestamp: number }
  try {
    runResult = await client.createAtcRun("SYNTAX_CHECK", packageUrl)
  } catch (e: any) {
    return { ok: false, error: `Failed to start ATC run (variant SYNTAX_CHECK) on ${pkg}: ${e.message || e}` }
  }

  // 3. Retrieve worklist (findings)
  let worklist: AtcWorkList
  try {
    worklist = await client.atcWorklists(runResult.id)
  } catch (e: any) {
    return { ok: false, error: `Failed to retrieve ATC worklist (run ID: ${runResult.id}): ${e.message || e}` }
  }

  // 4. Extract findings
  const findings: SyntaxFinding[] = []
  for (const obj of worklist.objects) {
    for (const finding of obj.findings) {
      findings.push({
        object: obj.name,
        objectType: obj.type,
        priority: finding.priority,
        checkTitle: finding.checkTitle,
        message: finding.messageTitle,
        line: finding.location.range.start.line,
        column: finding.location.range.start.column,
      })
    }
  }

  // 5. Format summary
  const summary = formatSummary(pkg, worklist, findings)

  return {
    ok: true,
    objectsChecked: worklist.objects.length,
    findingCount: findings.length,
    findings,
    summary,
  }
}

function formatSummary(pkg: string, worklist: AtcWorkList, findings: SyntaxFinding[]): string {
  const lines: string[] = []

  const errors = findings.filter((f) => f.priority === 1)
  const warnings = findings.filter((f) => f.priority === 2)
  const infos = findings.filter((f) => f.priority >= 3)

  if (findings.length === 0) {
    lines.push(`SYNTAX CHECK PASSED: No errors found in package ${pkg}.`)
    lines.push(`  Objects checked: ${worklist.objects.length}`)
    return lines.join("\n")
  }

  lines.push(`SYNTAX CHECK: ${errors.length} error(s), ${warnings.length} warning(s), ${infos.length} info(s)`)
  lines.push(`  Package: ${pkg}`)
  lines.push(`  Objects with findings: ${worklist.objects.length}`)
  lines.push("")

  for (const finding of findings) {
    const severity = finding.priority === 1 ? "ERROR" : finding.priority === 2 ? "WARN" : "INFO"
    lines.push(`  [${severity}] ${finding.objectType} ${finding.object}:${finding.line}`)
    lines.push(`         ${finding.message}`)
  }

  return lines.join("\n")
}
