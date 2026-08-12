# Surface Map

How to find the public surface and the consumers of any artifact, whatever the language or domain.

Read only the sections matching the manifests and file types the scope resolver reported.

- [Universal procedure](#universal-procedure)
- [In-repo code module](#in-repo-code-module)
- [Published package or library](#published-package-or-library)
- [HTTP / REST API](#http--rest-api)
- [GraphQL schema](#graphql-schema)
- [RPC and protobuf](#rpc-and-protobuf)
- [Database schema and migrations](#database-schema-and-migrations)
- [Events, messages, and queues](#events-messages-and-queues)
- [UI component](#ui-component)
- [CLI tool](#cli-tool)
- [Configuration and environment contract](#configuration-and-environment-contract)
- [Infrastructure as code](#infrastructure-as-code)
- [CI/CD pipeline](#cicd-pipeline)
- [Generated and mirrored code](#generated-and-mirrored-code)
- [Consumers that hide](#consumers-that-hide)

## Universal procedure

For any artifact, the same three questions resolve the surface:

1. **What can be referenced from outside?** Anything nameable across the boundary — a symbol, a route, a column, a key, a flag, a file path.
2. **What crosses the boundary at runtime?** Values, payloads, exit codes, side effects, timing, errors.
3. **What outlives the process?** Persisted rows, files, cache entries, published artifacts, logs someone parses.

Consumers are found by the inverse: search for the *name* of everything in the surface, then for the *shape* of what it emits (field names in JSON, column names in SQL, flag strings in shell).

If the artifact has no declared boundary, the surface is "everything currently referenced from outside" — compute it, and report the missing boundary as a Contract finding.

## In-repo code module

- **Surface** — exported/public symbols: functions, types, interfaces, constants, classes, decorators; re-exports from barrel or index files; interfaces the module expects others to implement; panics/exceptions it raises as part of its contract.
- **Find it** — export manifests (`exports`/`main` in `package.json`, `__all__`, `pub` items, capitalized Go identifiers, `export` statements, module definitions), and whatever a sibling module treats as its entry point.
- **Consumers** — grep for the import path and for each changed symbol name. Include subclasses and interface implementors, dependency-injection registrations, and reflection/dynamic lookups by string name.
- **Breaks when** — a symbol is removed, renamed, narrowed, made required, changed in arity or return shape, or changes behavior under the same signature.

## Published package or library

Everything above, plus: the package **is** its own consumer contract — you cannot enumerate downstream users, so every public export is a live contract and unverifiable consumers are warns by default.

- **Surface** — the published entry points, type declarations shipped alongside, peer/engine ranges, side effects on import, the license.
- **Find it** — `files`/`exports` fields, `.npmignore`, build output config, the packaged artifact listing (`npm pack --dry-run`, `go list ./...`, wheel contents).
- **Breaks when** — anything above, plus dropping a runtime/engine version, tightening a peer range, changing module format (CJS/ESM), or removing shipped types.

## HTTP / REST API

- **Surface** — method + path + path/query params, request and response body shapes, status codes, error envelope, headers (auth, content negotiation, pagination, caching), rate limits, idempotency semantics.
- **Find it** — route registrations, controller annotations, an OpenAPI document, gateway/proxy config.
- **Consumers** — in-repo clients and SDKs, frontend fetch calls (grep the path string, including templated fragments), other services, webhooks pointed at it, mobile app versions still in the wild, external integrators.
- **Breaks when** — a route or field is removed or renamed, a field becomes required, a type narrows, a status code or error shape changes, defaults change, validation tightens, or a previously optional auth becomes mandatory. Note that mobile and third-party clients cannot be updated in lockstep — those are warns at minimum.

## GraphQL schema

- **Surface** — types, fields, arguments, enum values, directives, nullability, deprecations.
- **Consumers** — every persisted query and client document; generated client types.
- **Breaks when** — a field or enum value is removed, an argument becomes required, a nullable field becomes non-null on input (or non-null becomes nullable on output), a type changes kind.

## RPC and protobuf

- **Surface** — services, methods, message fields with their numbers, streaming mode, error codes and details.
- **Breaks when** — a field number is reused or changed, a field type changes, a method is removed or renamed, `optional`/`required` semantics change, or streaming mode changes. Wire compatibility and source compatibility differ — check both.

## Database schema and migrations

- **Surface** — tables, columns, types, nullability, defaults, constraints, indexes relied on by queries, view and function definitions, enum values.
- **Consumers** — every query and ORM model, read replicas, reporting and analytics jobs, ETL pipelines, dashboards, other services sharing the database, backup/restore tooling.
- **Breaks when** — a column is dropped or renamed, a type narrows, `NOT NULL` is added without a default and backfill, an enum value is removed, a unique constraint is added over non-unique data, or an index a hot query depends on disappears.
- **Also check** — reversibility of the migration, lock duration on a large table, and whether old application instances can still read and write during rollout.

## Events, messages, and queues

- **Surface** — topic/queue/channel names, payload schema, key and partitioning scheme, headers, ordering and delivery guarantees, retention, dead-letter behavior.
- **Consumers** — every subscriber, including ones in other repos, plus replay tooling and anything reading the archive of past messages.
- **Breaks when** — a field is removed or retyped, semantics of an existing field shift, the key scheme changes (repartitioning), or a new required field lands while old producers still emit messages without it. Historical messages already in the log are permanent consumers of the old schema.

## UI component

- **Surface** — props/inputs and their types, required vs optional, slots/children/composition points, emitted events and their payloads, exposed refs/imperative handles, CSS custom properties, class names and data attributes that others style or select, accessibility roles and labels.
- **Consumers** — every render site, snapshot and E2E tests selecting by role/text/testid, stylesheets targeting its classes, design-system documentation.
- **Breaks when** — a prop is renamed or made required, default styling shifts layout, a DOM structure or class name that selectors depend on changes, an event payload changes, or keyboard/ARIA behavior regresses.

## CLI tool

- **Surface** — commands, subcommands, flags and aliases, positional arguments, stdin/stdout format, exit codes, environment variables read, config file location, side effects on the filesystem.
- **Consumers** — scripts, CI pipelines, Makefiles, Dockerfiles, docs and READMEs with copy-paste commands, other tools shelling out to it, users' shell aliases and history.
- **Breaks when** — a flag is renamed or removed, a default changes, output format changes for anything that gets piped or parsed, or an exit code changes meaning. Human-readable output that a script greps is a de-facto contract.

## Configuration and environment contract

- **Surface** — every key, its type, whether it is required, its default, its precedence order, and the file's schema version.
- **Consumers** — deployment manifests per environment, secret stores, local `.env` templates, onboarding docs, IaC that renders the config, and every environment already running with the old shape.
- **Breaks when** — a key is renamed or removed, a default changes, a key becomes required without a default, validation tightens, or precedence changes. A config change is deployed independently of code — assume old code will meet new config and vice versa.

## Infrastructure as code

- **Surface** — resource names and identifiers, module inputs and outputs, exposed ports and endpoints, IAM roles and permissions, resource limits, labels and selectors others match on, storage class and volume identity.
- **Consumers** — other modules importing the outputs, services resolving the endpoints, monitoring and alerting selecting by label, anything holding the state file.
- **Breaks when** — a resource is renamed such that the plan replaces rather than updates it (destroy-and-recreate on stateful resources is a data-breaking change), an output is removed, a selector or label changes, a permission narrows, or a limit drops below observed usage.

## CI/CD pipeline

- **Surface** — job and stage names other configs depend on, required status checks, produced artifacts and their names, cache keys, secrets consumed, triggers, and the contract with branch-protection rules.
- **Breaks when** — a required check is renamed (branch protection then waits forever), an artifact name changes, a cache key format changes, or a job's permissions narrow.

## Generated and mirrored code

Some repositories keep a second copy of the same content: a mirrored plugin directory, a vendored tree, generated clients, translation catalogs, or paired definitions for two hosts.

- **Surface** — the invariant "copy A equals copy B", or "generated output matches its source".
- **Check** — whether the generator was re-run and whether every mirror was updated. A change to one side only is a Completeness blocker even if both sides compile.
- **Find them** — a sync step in a release script, a `go:generate`/codegen config, a `--check` mode in CI, or two paths with suspiciously similar file listings.

## Consumers that hide

Static import graphs miss these. Search for them explicitly whenever the surface changed:

- **String-based access** — reflection, dynamic import, dependency-injection by name, template rendering, `getattr`, serialization by field name.
- **Cross-repo consumers** — other services, mobile clients pinned to old versions, partner integrations, published SDKs.
- **Non-code consumers** — documentation and tutorials, runbooks, dashboards and saved queries, alert rules, support macros.
- **Data already at rest** — rows, cached entries, queued messages, and log archives written under the old shape.
- **Test doubles** — mocks, stubs, fixtures, and contract tests that encode the old surface and will silently keep passing while production breaks.
- **Time-shifted consumers** — the previous deployed version during a rolling release, and anything that must roll back to it.
