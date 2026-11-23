import { readFileSync } from "node:fs"
import { ADTClient, createSSLConfig } from "abap-adt-api"

/**
 * Creates an ADT client. caFile: PEM file with the CA the SAP system's TLS
 * certificate chains to (e.g. self-hosted systems signed by SAP Global Root CA).
 */
export function createAdtClient(url: string, user: string, password: string, caFile?: string): ADTClient {
  const options = caFile ? createSSLConfig(false, readFileSync(caFile, "utf-8")) : undefined
  return new ADTClient(url, user, password, undefined, undefined, options)
}
