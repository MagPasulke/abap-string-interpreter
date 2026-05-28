/**
 * ICF shim server helper.
 * Sets up Express + express-icf-shim + in-memory SQLite for integration testing.
 */
import express from 'express';
import dbPkg from '@abaplint/database-sqlite';
const {SQLiteDatabaseClient} = dbPkg;
import {initializeABAP} from "../../../output/init.mjs";
import {cl_express_icf_shim} from "../../../output/cl_express_icf_shim.clas.mjs";

await initializeABAP();

// Set up in-memory SQLite database
const db = new SQLiteDatabaseClient();
await db.connect();
await db.execute(`CREATE TABLE 'zasis_rulesethd' ('client' NCHAR(3) COLLATE RTRIM, 'rulesetuuid' NCHAR(32), 'rulesetid' NCHAR(12) COLLATE RTRIM, 'attachment' TEXT, 'mimetype' NCHAR(128) COLLATE RTRIM, 'filename' NCHAR(128) COLLATE RTRIM, 'last_changed_by' NCHAR(12) COLLATE RTRIM, 'last_changed_at' DECIMAL(21,7), 'local_last_changed_at' DECIMAL(21,7), PRIMARY KEY('client','rulesetuuid'));`);
await db.execute(`CREATE TABLE 'zasis_rulesetitm' ('client' NCHAR(3) COLLATE RTRIM, 'rulesetuuid' NCHAR(32), 'interpretationitm' NCHAR(32), 'intpretationtarget' NCHAR(12) COLLATE RTRIM, 'interpretationrule' NCHAR(1000) COLLATE RTRIM, 'interpretation_type' NCHAR(1) COLLATE RTRIM, 'offset_pre' INT, 'offset_post' INT, 'replacement_string' NCHAR(15) COLLATE RTRIM, 'custom_logic' NCHAR(30) COLLATE RTRIM, 'event_producer' NCHAR(30) COLLATE RTRIM, 'last_changed_by' NCHAR(12) COLLATE RTRIM, 'last_changed_at' DECIMAL(21,7), 'local_last_changed_at' DECIMAL(21,7), PRIMARY KEY('client','rulesetuuid','interpretationitm'));`);
abap.context.databaseConnections["DEFAULT"] = db;

// Seed test fixture data into in-memory transparent tables
async function seedTestData() {
  // Insert header for test ruleset "TestRS"
  const header = new abap.types.Structure({
    client: new abap.types.Character(3, {qualifiedName: "MANDT"}),
    rulesetuuid: new abap.types.Hex({length: 16}),
    rulesetid: new abap.types.Character(30),
    attachment: new abap.types.XString(),
    mimetype: new abap.types.Character(128),
    filename: new abap.types.Character(128),
    last_changed_by: new abap.types.Character(12),
    last_changed_at: new abap.types.Packed({length: 11, decimals: 7}),
    local_last_changed_at: new abap.types.Packed({length: 11, decimals: 7}),
  });
  header.get().client.set("000");
  header.get().rulesetuuid.set("AABBCCDD11223344");
  header.get().rulesetid.set("TestRS");
  await abap.statements.insertDatabase("zasis_rulesethd", {values: header});

  // Insert items: one MATCH rule for MaterialNo, one MATCH rule for DeliveryNo
  const item1 = new abap.types.Structure({
    client: new abap.types.Character(3, {qualifiedName: "MANDT"}),
    rulesetuuid: new abap.types.Hex({length: 16}),
    interpretationitm: new abap.types.Numc({length: 4}),
    intpretationtarget: new abap.types.Character(30),
    interpretationrule: new abap.types.Character(255),
    interpretation_type: new abap.types.Numc({length: 1}),
    offset_pre: new abap.types.Numc({length: 4}),
    offset_post: new abap.types.Numc({length: 4}),
    replacement_string: new abap.types.Character(255),
    custom_logic: new abap.types.Character(30),
    event_producer: new abap.types.Character(30),
    last_changed_by: new abap.types.Character(12),
    last_changed_at: new abap.types.Packed({length: 11, decimals: 7}),
    local_last_changed_at: new abap.types.Packed({length: 11, decimals: 7}),
  });
  item1.get().client.set("000");
  item1.get().rulesetuuid.set("AABBCCDD11223344");
  item1.get().interpretationitm.set("0001");
  item1.get().intpretationtarget.set("MaterialNo");
  item1.get().interpretationrule.set("<A7X>([^<]*)");
  item1.get().interpretation_type.set("1");
  item1.get().offset_pre.set("0005");
  item1.get().offset_post.set("0000");
  await abap.statements.insertDatabase("zasis_rulesetitm", {values: item1});

  const item2 = new abap.types.Structure({
    client: new abap.types.Character(3, {qualifiedName: "MANDT"}),
    rulesetuuid: new abap.types.Hex({length: 16}),
    interpretationitm: new abap.types.Numc({length: 4}),
    intpretationtarget: new abap.types.Character(30),
    interpretationrule: new abap.types.Character(255),
    interpretation_type: new abap.types.Numc({length: 1}),
    offset_pre: new abap.types.Numc({length: 4}),
    offset_post: new abap.types.Numc({length: 4}),
    replacement_string: new abap.types.Character(255),
    custom_logic: new abap.types.Character(30),
    event_producer: new abap.types.Character(30),
    last_changed_by: new abap.types.Character(12),
    last_changed_at: new abap.types.Packed({length: 11, decimals: 7}),
    local_last_changed_at: new abap.types.Packed({length: 11, decimals: 7}),
  });
  item2.get().client.set("000");
  item2.get().rulesetuuid.set("AABBCCDD11223344");
  item2.get().interpretationitm.set("0002");
  item2.get().intpretationtarget.set("DeliveryNo");
  item2.get().interpretationrule.set("<B52H>([^<]*)");
  item2.get().interpretation_type.set("1");
  item2.get().offset_pre.set("0006");
  item2.get().offset_post.set("0000");
  await abap.statements.insertDatabase("zasis_rulesetitm", {values: item2});
}

export async function startServer(quiet) {
  const PORT = 3040;

  await seedTestData();

  const app = express();
  app.disable('x-powered-by');
  app.set('etag', false);
  app.use(express.raw({type: "*/*"}));

  app.all("/zasis/*", async function (req, res) {
    await cl_express_icf_shim.run({
      req,
      res,
      class: "ZASIS_CL_HTTP_HANDLER",
      base: new abap.types.String().set("/zasis")
    });
  });

  const server = app.listen(PORT);
  if (quiet !== true) {
    console.log("ICF shim server listening on http://localhost:" + PORT + "/zasis");
  }

  return server;
}
