INTERFACE zasis_if_config
  PUBLIC.

  "! Returns the maximum number of items per bulk request.
  "! Falls back to zasis_constants=>bulk-max_items if no valid positive integer is configured.
  METHODS get_bulk_max_items
    RETURNING
      VALUE(max_items) TYPE i.

ENDINTERFACE.
