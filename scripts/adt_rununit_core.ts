import { ADTClient, UnitTestClass, UnitTestAlert, UnitTestAlertKind } from "abap-adt-api"

export interface AdtRunUnitOptions {
  /** SAP system base URL (e.g. https://host:44300) */
  url: string
  /** SAP user */
  user: string
  /** SAP password */
  password: string
  /** Object type: CLAS or DEVC. Defaults to DEVC when objectName is from SAP_ROOT_PACKAGE. */
  objectType: "CLAS" | "DEVC"
  /** Object name (e.g. ZASIS_CL_INTERPRETER or ZASIS) */
  objectName: string
}

export interface AdtRunUnitSuccess {
  ok: true
  summary: string
}

export interface AdtRunUnitError {
  ok: false
  error: string
}

export type AdtRunUnitResult = AdtRunUnitSuccess | AdtRunUnitError

/** Build the ADT URI for the given object type and name */
function buildUri(objectType: "CLAS" | "DEVC", objectName: string): string {
  const name = objectName.toLowerCase()
  switch (objectType) {
    case "CLAS":
      return `/sap/bc/adt/oo/classes/${name}`
    case "DEVC":
      return `/sap/bc/adt/packages/${name}`
  }
}

/** Format a single alert into readable text */
function formatAlert(alert: UnitTestAlert): string {
  const lines: string[] = []
  const kindLabel = alert.kind === UnitTestAlertKind.failedAssertion
    ? "Assertion Failed"
    : alert.kind === UnitTestAlertKind.exception
      ? "Exception"
      : "Warning"
  lines.push(`      [${kindLabel}] ${alert.title}`)
  for (const detail of alert.details) {
    if (detail.trim()) {
      lines.push(`        ${detail}`)
    }
  }
  if (alert.stack.length > 0) {
    const top = alert.stack[0]
    lines.push(`        at ${top["adtcore:name"]} (${top["adtcore:uri"]})`)
  }
  return lines.join("\n")
}

/** Format full unit test results into a human-readable summary */
function formatResults(classes: UnitTestClass[], target: string): string {
  let totalMethods = 0
  let passed = 0
  let failed = 0
  let totalTime = 0
  const failures: string[] = []

  for (const cls of classes) {
    // Class-level alerts
    if (cls.alerts.length > 0) {
      for (const alert of cls.alerts) {
        if (alert.kind !== UnitTestAlertKind.warning) {
          failed++
          totalMethods++
          failures.push(`    ${cls["adtcore:name"]}:`)
          failures.push(formatAlert(alert))
        }
      }
    }

    for (const method of cls.testmethods) {
      totalMethods++
      totalTime += method.executionTime
      if (method.alerts.length > 0) {
        const hasFailure = method.alerts.some(
          (a) => a.kind !== UnitTestAlertKind.warning
        )
        if (hasFailure) {
          failed++
          failures.push(`    ${cls["adtcore:name"]}->${method["adtcore:name"]}:`)
          for (const alert of method.alerts) {
            failures.push(formatAlert(alert))
          }
        } else {
          passed++
        }
      } else {
        passed++
      }
    }
  }

  const status = failed > 0 ? "FAILED" : "PASSED"
  const lines: string[] = []
  lines.push(`UNIT TESTS ${status}: ${passed}/${totalMethods} passed, ${failed} failed`)
  lines.push(`  Target: ${target}`)
  lines.push(`  Classes: ${classes.length}`)
  lines.push(`  Duration: ${totalTime}ms`)

  if (failures.length > 0) {
    lines.push("")
    lines.push("  Failures:")
    lines.push(...failures)
  }

  return lines.join("\n")
}

/**
 * Triggers ABAP Unit tests on a SAP system for the specified object.
 */
export async function adtRunUnit(options: AdtRunUnitOptions): Promise<AdtRunUnitResult> {
  const { url, user, password, objectType, objectName } = options

  // 1. Connect to SAP system
  let client: ADTClient
  try {
    client = new ADTClient(url, user, password)
  } catch (e: any) {
    return { ok: false, error: `Failed to create ADT client: ${e.message || e}` }
  }

  // 2. Build target URI
  const uri = buildUri(objectType, objectName)
  const target = `${objectType} ${objectName.toUpperCase()} (${uri})`

  // 3. Run unit tests
  let results: UnitTestClass[]
  try {
    results = await client.unitTestRun(uri)
  } catch (e: any) {
    return {
      ok: false,
      error: `Unit test run failed for ${target}: ${e.message || e}`,
    }
  }

  // 4. Format and return results
  if (results.length === 0) {
    return {
      ok: true,
      summary: `UNIT TESTS PASSED: 0/0 passed, 0 failed\n  Target: ${target}\n  No test classes found.`,
    }
  }

  return {
    ok: true,
    summary: formatResults(results, target),
  }
}
