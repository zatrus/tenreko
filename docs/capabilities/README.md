# Capabilities: current behaviour

One file per capability (`checkout.md`, `user-accounts.md`), describing **what the system does today**. This is the place to look up current behaviour.

| | `docs/capabilities/<name>.md` | `docs/specs/NNN-slug/` |
|---|---|---|
| Answers | How does it behave **now**? | What did **one change** add or alter, and how was it built? |
| Lifetime | Living: kept current with every merged change | Historical once delivered: never edited again |
| Updated by | `/spec-verify` (before the PR), `/bugfix` when it restores or clarifies a rule, `/spec-extract` for existing code | `/spec-new`, `/spec-design`, `/spec-tasks` |

Rules:
- A change spec names the capabilities it touches (*Capabilities* line in `requirements.md`). `/spec-verify` folds its approved REQs into those files before opening the PR, so the PR merges code and current behaviour together.
- Rule IDs are stable per capability: `CHECKOUT-1`, `CHECKOUT-2`, and so on. Never renumber. A removed rule is ~~struck through~~ with the spec that removed it.
- Each rule links back to the change REQ that introduced it, and to its test(s).
- Old `design.md` files are not the current architecture. Lasting decisions belong in an ADR (`docs/adr/`) and are linked from here.
- If the code, a capability file, and a change spec disagree, don't pick one. Report the conflict and ask the human (hard rule 7).

Template: [`_template.md`](_template.md).

## Index

Source: `D:\projects\reservations` (extracted with `/spec-extract`). Paths below are relative to it.
`O/` = `binturo-organizers/backend/app/`, `P/` = `binturo-platform/backend/app/`, `OT/` and `PT/` = their `tests/` folders.
Size = router + service files: S ≤ 4, M 5 to 9, L ≥ 10.

| Capability | Prefix | File | Main code | Tests | Entry points | Size | Last changed by |
|---|---|---|---|---|---|---|---|
| Accounts and access | AUTH | `accounts-and-access.md` | O/routers/{auth,all_users,users,staff,setup}.py, O/services/{account,all_users,identity,role_assignment,staff,users}_service.py, O/services/login_throttle.py, O/auth/, P/routers/{auth,setup,operators}.py, P/services/{password_reset,operators}_service.py, P/services/login_throttle.py | OT/test_auth_*.py, OT/test_services_{account,all_users,identity,login_throttle,role_assignment,staff,users}.py, OT/test_routers_auth_reset_link.py, PT/test_services_{password_reset,operators,login_throttle}.py | /api/auth/*, /api/accounts, /api/users, /api/staff, /api/setup (both backends), /api/operators | L | pending extraction |
| Studio catalogue | CATALOG | `studio-catalogue.md` | O/routers/{locations,class_types,seasons}.py, O/services/{locations,class_types,seasons}_service.py, O/services/polish_holidays.py | OT/test_services_{locations,class_types,seasons}.py, OT/test_polish_holidays.py | /api/locations (+ rooms), /api/class-types, /api/seasons (+ closed days, holidays) | M | pending extraction |
| Organizer profile and settings | SETTINGS | `organizer-settings.md` | O/routers/{organizer_profile,settings,billing_info,legal_links}.py and their services, P/routers/platform_settings.py, P/services/{platform_settings,billing_info}_service.py | OT/test_services_{organizer_profile,settings,billing_info,legal_links}.py, PT/test_services_billing_info.py, PT/test_schemas_platform_settings.py | /api/organizer-profile, /api/settings, /api/billing-info, /api/legal-links, /api/platform-settings | L | pending extraction |
| Trainer availability | TRAINER | `trainer-availability.md` | O/routers/trainers.py, O/services/trainers_service.py | OT/test_services_trainers.py, OT/test_schemas_user_trainer.py | /api/trainers (weekly schedule, exceptions, copy to other organizers) | S | pending extraction |
| Class schedule | SCHED | `class-schedule.md` | O/routers/schedules.py, O/services/{schedules,schedule_notifications}_service.py | OT/test_services_{schedules,schedule_notifications}.py | /api/schedules (single, recurring, cancel, cancel preview) | S | pending extraction |
| Enrollments | ENROLL | `enrollments.md` | O/routers/enrollments.py, O/services/enrollments_service.py, O/services/enrollment_errors.py | OT/test_services_enrollments.py | /api/enrollments (own, all organizers, guests, cancel, mark paid, revert payment) | S | pending extraction |
| Passes and price lists | PASS | `passes-and-pricing.md` | O/routers/{pass_types,passes,price_lists}.py and their services | OT/test_services_{pass_types,passes,price_lists}.py | /api/pass-types, /api/passes, /api/price-lists | M | pending extraction |
| Client payments and refunds | PAY | `payments-and-refunds.md` | O/routers/{checkout,payment_provider,refunds,webhooks}.py, O/services/{checkout,payment_provider,refunds}_service.py, O/integrations/ | OT/test_services_{checkout,payment_provider,refunds}.py, OT/test_integrations_{stripe,mock}_gateway.py | /api/checkout/*, /api/payment-provider/*, /api/refunds/*, POST /api/webhooks/stripe | M | pending extraction |
| Messaging and notifications | MSG | `messaging.md` | O/routers/{client_messages,messages,trainer_messages,incident_messages}.py and their services, O/services/{email_service,message_html}.py, O/email/, P/routers/{messages,client_incident_messages}.py, P/services/{messages,client_incident_messages,notifications,email}_service.py | OT/test_services_{client_messages_moderation,messages_moderation,messages_visibility,trainer_messages,incident_messages}.py, OT/test_email_*.py, PT/test_services_{notifications,client_incident_messages}.py, PT/test_email_*.py | /api/{client,trainer,incident}-messages, /api/messages (both), /api/client-incident-messages, cron `--run-cron` (unread notifications, expiry reminders) | L | pending extraction |
| Content moderation | MOD | `content-moderation.md` | O/routers/moderation.py, O/services/moderation_service.py, O/moderation/, P/routers/moderation.py, P/services/{moderation_integration,moderation_review}_service.py | OT/test_services_moderation.py, OT/test_moderation_client_selection.py, PT/test_services_moderation_{integration,review}.py | /api/internal/moderation, /api/moderation (queue, resolve, history, summary) | M | pending extraction |
| Personal data erasure | ERASE | `data-erasure.md` | O/routers/erasure.py, O/services/erasure_service.py, anonymize routes in O/routers/{all_users,users,enrollments}.py, P/services/erasure_cron_service.py | OT/test_services_erasure.py, PT/test_services_erasure_cron.py | /api/auth/me/erasure, POST /api/internal/erasure/run-due, /anonymize routes, cron | S | pending extraction |
| Organizer onboarding and tenancy | TENANT | `organizer-tenancy.md` | P/routers/organizers.py, P/services/{organizers,provisioning,migration_run,schema_version}_service.py, P/services/subprocess_env.py, O/services/organizer_lookup_service.py, binturo-organizers/backend/binturo.py | PT/test_services_{organizers,provisioning,migration_run,schema_version,subprocess_env}.py, OT/test_services_organizer_lookup.py | /api/organizers/* (self-register, provision, migrate), CLI `--migrate-schema` | M | pending extraction |
| Organizer subscriptions | SUB | `organizer-subscriptions.md` | O/routers/subscription.py, O/services/subscription_service.py, P/routers/{subscription_plans,internal,webhooks}.py, P/services/{subscription,subscription_payment,subscription_plans,client_limits}_service.py | OT/test_services_subscription.py, PT/test_services_{subscription,subscription_payment,subscription_plans}.py | /api/subscription/*, /api/subscription-plans, /api/internal/organizers/{id}/subscription/*, POST /api/webhooks/stripe-subscriptions, cron (limit checks) | M | pending extraction |
| Activity log and metrics | AUDIT | `activity-and-metrics.md` | O/routers/activity_log.py, O/services/{activity_log,organization_metrics}_service.py, O/metrics.py, P/routers/activity_log.py, P/services/{activity_log,organization_metrics}_service.py | OT/test_services_{activity_log,organization_metrics}.py, OT/test_metrics.py, OT/test_organization_metrics_gauges.py, PT/ same names, PT/test_cron_metrics.py | /api/activity-log (both), Prometheus metrics | M | pending extraction |
