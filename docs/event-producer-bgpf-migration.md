# Event Producer: Future Migration to bgPF

## Current State

The event producer is called **synchronously** after each successful item interpretation in `zasis_cl_interpreter`. This means the event producer executes in the same LUW as the interpretation itself.

## Future: Background Processing Framework (bgPF)

When upgrading to **SAP BTP ABAP Environment 2308+** or a newer ABAP Platform release that includes the bgPF, the event producer invocation should be migrated to **asynchronous execution** using `CL_BGMC_PROCESS_FACTORY`.

### Benefits of bgPF

- **Transactional consistency**: Executes in a separate session after COMMIT WORK
- **Better end-user performance**: Post-processing doesn't block the response
- **Exactly-once guarantee**: Built on bgRFC with reliable delivery
- **Testability**: `CL_BGMC_TEST_ENVIRONMENT` for unit testing

### Migration Steps

1. Replace the direct synchronous call in `zasis_cl_interpreter=>call_event_producer` with bgPF scheduling
2. Create a bgPF-compatible wrapper class that implements the background process interface
3. The wrapper receives serialized parameters (ruleset ID, item number, result) and re-instantiates the event producer in the background session
4. Use `CL_BGMC_PROCESS_FACTORY=>get_default( )->create( )` to schedule the background process

### References

- [SAP Help: Background Processing Framework](https://help.sap.com/docs/ABAP_Cloud/f2961be2bd3d403585563277e65d108f/e1fbe70d8dd54a2db2df3a208b2cb68e.html)
- Released classes: `CL_BGMC_PROCESS_FACTORY`, `CL_BGMC_TEST_ENVIRONMENT` (Level A, BC-MID-BGM)
