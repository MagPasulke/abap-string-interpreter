/**
 * Database setup for the transpiled ABAP Unit tests (npm run unit).
 * Referenced from abap_transpile.json (options.setup) and called by output/init.mjs.
 * Provides an in-memory SQLite database so that cl_osql_test_environment works.
 */
import dbPkg from '@abaplint/database-sqlite';
const { SQLiteDatabaseClient } = dbPkg;

export async function initDatabase(abap, schemas, insert) {
  const db = new SQLiteDatabaseClient();
  // register before connect( ), which then sets sy-dbsys (required by cl_osql_test_environment)
  abap.context.databaseConnections["DEFAULT"] = db;
  await db.connect();
  await db.execute(schemas.sqlite);
  await db.execute(insert);
}
