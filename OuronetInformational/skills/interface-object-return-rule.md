## Interface object-return rule

When an interface function returns `object{...}` where that schema is defined inside the implementing module, deployment order becomes a problem (interface is loaded before module schemas exist).

Use one of two patterns:

1. Remove those functions from the interface.
2. Move the schema definition to the interface, then keep the function in the interface.

Current Ouronet convention:

- Keep schemas in the module.
- Remove from interfaces any function that returns an object typed by a module-local schema.

Applied for `AQP-ANK` and `AQP-SCORE` interfaces.
