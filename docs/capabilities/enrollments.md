# Capability: Enrollments

- **Prefix:** `ENROLL` (rule IDs `ENROLL-1`, `ENROLL-2`, …)
- **Last changed by:** extracted 2026-10-25 (`/spec-extract`)
- **Business context:** [BUSINESS.md](../BUSINESS.md) (terms used here are defined there)
- **Source root:** `D:\projects\reservations`. Paths below are relative to it.
  - `router` = `binturo-organizers/backend/app/routers/enrollments.py`
  - `svc` = `binturo-organizers/backend/app/services/enrollments_service.py`
  - `schema` = `binturo-organizers/backend/app/schemas/enrollment.py`
  - `O/` = `binturo-organizers/backend/app/`
  - Every test named `test_…` is in `binturo-organizers/backend/tests/test_services_enrollments.py`. All of these tests use a mocked `AsyncSession` (no real database). No router-level test exists for this capability.

## Purpose
Clients enroll themselves on scheduled classes, and staff (admin, reception) enroll clients or guests without an account. The capability also covers cancellation with waitlist promotion, the staff action "mark as paid" on the day of the class, and its reversal.

Statuses (`EnrollmentStatus`, `O/models/enrollment.py:16`): `confirmed`, `waitlist`, `cancelled`, `attended`.
- **Active** = `confirmed`, `waitlist`, `attended` (`svc:39`).
- **Occupies a seat** = `confirmed`, `attended` (`svc:47`). The "confirmed count" of a class counts these two (`svc:72`).

## Rules (current behaviour)

"Now" in time rules means the server's local wall clock with the UTC label added (`datetime.now().replace(tzinfo=timezone.utc)`). Class start times are stored the same way (see the time-zone open question).

### Reading enrollments

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-1 | WHEN an authenticated user with an unlocked subscription calls `GET /api/enrollments/me`, the system shall return all of that user's enrollments in the current organizer, in every status (cancelled included), ordered by class start, newest first. | extracted 2026-10-25 | `router:39`, `svc:821` | — (code only) |
| ENROLL-2 | WHERE `from_date` is given on `GET /enrollments/me`, `GET /enrollments/me/all` or `GET /enrollments?user_id=`, the system shall return only enrollments on classes that start at or after 00:00 of that date. WHERE it is absent, the system shall return the full history. | extracted 2026-10-25 | `svc:830` | — (code only) |
| ENROLL-3 | WHEN a user calls `GET /api/enrollments/me/all`, the system shall return the caller's own enrollments from every organizer where the global identity has an active membership with a local account, tag each item with the organizer code and name, and sort all items by class start, newest first. No role and no subscription check applies (only a valid token). | extracted 2026-10-25 | `router:51`, `svc:840` | `test_list_for_user_all_organizers_aggregates_and_tags_organizer` |
| ENROLL-4 | IF a membership has no local user ID, or its schema does not resolve to an organizer, THEN the system shall skip that membership without an error. | extracted 2026-10-25 | `svc:857`, `svc:859` | `test_list_for_user_all_organizers_skips_unknown_schema` |
| ENROLL-5 | WHEN staff call `GET /api/enrollments?user_id=`, the system shall return that client's enrollments as in ENROLL-1. IF the user does not exist or has no `member` role, THEN the system shall return 404 "Klient nie istnieje". | extracted 2026-10-25 | `router:207`, `O/services/users_service.py:83` | — (code only) |
| ENROLL-6 | IF the caller's active role is not admin, reception or trainer on `GET /api/enrollments/schedule/{id}`, THEN the system shall return 403. WHERE the active role is trainer, IF the class does not exist THEN 404, and IF the class belongs to another trainer THEN 403. Admin and reception see the roster of any class. | extracted 2026-10-25 | `router:223` | — (code only) |
| ENROLL-7 | WHEN the roster of a class is requested, the system shall return all non-cancelled enrollments, with rows that have no waitlist position (confirmed, attended) first and waitlist rows after them by position. No other sort key is applied. IF the class does not exist (admin, reception), THEN the system shall return an empty list. | extracted 2026-10-25 | `svc:871`, `svc:886` | `test_list_for_schedule_returns_client_info`, `test_list_for_schedule_empty_when_no_enrollments` |
| ENROLL-8 | WHEN a roster row is a guest without an account, the system shall return a client with `id = null`, the guest first and last name, `phone = null`, and the guest email. | extracted 2026-10-25 | `svc:936` | `test_list_for_schedule_returns_guest_client_without_account` |
| ENROLL-9 | WHEN a roster row has an account, status `confirmed`, no `paid_at`, is not free, and has no pass, the system shall add `eligible_pass` (the pass that ENROLL-32 would pick today). For all other rows `eligible_pass` is null. | extracted 2026-10-25 | `svc:904` | `test_list_for_schedule_surfaces_eligible_pass_for_unpaid_confirmed`, `test_list_for_schedule_no_eligible_pass_when_already_paid` |
| ENROLL-10 | WHEN staff call `GET /api/enrollments/guests?q=`, the system shall return guest enrollments (no account) where the first name OR the last name contains `q`, case-insensitive, with `%` and `_` matched literally, ordered by class start, oldest first. Cancelled enrollments are excluded unless `include_cancelled=true`. IF `q` has fewer than 2 characters, THEN the system shall return 422. | extracted 2026-10-25 | `router:242`, `svc:966`, `O/services/search.py:1` | `test_search_guest_enrollments_returns_matches` (asserts only that rows are returned) |

### Creating an enrollment: client self-service

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-11 | WHEN a user whose active role is `member` (subscription unlocked) calls `POST /api/enrollments/me` with `class_schedule_id`, the system shall try to enroll that user. The body has no `user_id` and no `force`. Other active roles get 403. | extracted 2026-10-25 | `router:150`, `schema:39`, `O/auth/dependencies.py:95` | — (code only) |
| ENROLL-12 | IF the class does not exist, THEN the system shall reject the enrollment with 404. IF the class status is not `scheduled`, THEN the system shall reject it with 400. This applies to self-service and staff. | extracted 2026-10-25 | `svc:285` | `test_create_enrollment_schedule_not_found`, `test_create_enrollment_schedule_not_open` |
| ENROLL-13 | IF a self-service enrollment targets a class whose start is at or before now, THEN the system shall reject it with 409 (class already started). | extracted 2026-10-25 | `svc:173` | `test_create_enrollment_self_service_blocks_already_started_class` |
| ENROLL-14 | IF a self-service enrollment targets a class that starts later than now + `client_booking_horizon_days` (default 7, minimum 1), THEN the system shall reject it with 409. A start exactly at the horizon end is allowed. | extracted 2026-10-25 | `svc:177`, `O/models/organizer_settings.py:19` | `test_create_enrollment_self_service_blocks_outside_horizon`, `test_create_enrollment_self_service_allowed_within_horizon` |
| ENROLL-15 | IF the client already has an active enrollment on the same class, THEN the system shall reject the enrollment with 409 (already reserved). | extracted 2026-10-25 | `svc:190` | `test_create_enrollment_already_reserved` |
| ENROLL-16 | IF the client has an active enrollment (waitlist included) on another class whose time overlaps (other start < this end AND other end > this start, any location), THEN the system shall reject the enrollment with 409 and a message that names the other class type and its `HH:MM–HH:MM`. Classes that only touch (end = start) do not overlap. | extracted 2026-10-25 | `svc:204` | `test_create_enrollment_overlapping_enrollment` |
| ENROLL-17 | IF the class is full (seat-occupying count ≥ capacity) on a self-service enrollment, THEN the system shall reject it with 409 "Brak wolnych miejsc na te zajęcia" and shall never put the client on the waitlist, even if `force` reaches the service. | extracted 2026-10-25 | `svc:339`, `router:144` | `test_create_enrollment_self_service_full_room_blocked_even_with_force` |
| ENROLL-18 | WHEN a user calls `POST /api/enrollments/me/all-organizers` with `organizer_code` and `class_schedule_id`, the system shall resolve the organizer, then enroll the matching local user with ENROLL-12 to ENROLL-17. IF the identity has no active membership with a local account in that organizer, or the local user is missing, inactive, or lacks the `member` role, THEN the system shall return 403 "Brak dostępu do tej organizacji". Unknown or inactive organizer codes are rejected by `resolve_active_organizer` (status codes not read). | extracted 2026-10-25 | `router:164` | — (code only) |

### Creating an enrollment: staff

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-19 | WHEN staff (active role admin or reception, or trainer when the organizer has `simplified_mode`) call `POST /api/enrollments`, the system shall accept either `user_id` or a non-blank `first_name` and `last_name`. IF neither is given, THEN the system shall return 422. IF `user_id` is given, the name, phone and email fields are ignored. | extracted 2026-10-25 | `router:280`, `schema:32`, `O/auth/dependencies.py:113` | — (code only) |
| ENROLL-20 | IF `user_id` points to a missing user or to a user without the `member` role, THEN the system shall return 404 "Klient nie istnieje". The user's `is_active` flag is not checked. | extracted 2026-10-25 | `svc:297`, `router:317` | `test_create_enrollment_user_not_found`, `test_create_enrollment_user_not_member` |
| ENROLL-21 | WHEN staff give names without `user_id` and without a phone, the system shall create a guest enrollment: `user_id` null, guest first name, last name and email stored on the enrollment, no account created. This is also true when the given email belongs to an existing account. | extracted 2026-10-25 | `svc:125`, `router:301` | `test_resolve_or_register_client_no_phone_returns_guest`, `test_create_enrollment_guest_confirmed_when_room_available` |
| ENROLL-22 | WHEN staff give names and a phone, and the email matches a local account in this organizer, the system shall enroll that account and ignore the other form data. | extracted 2026-10-25 | `svc:128` | `test_resolve_or_register_client_existing_email_reuses_account` |
| ENROLL-23 | WHEN staff give names and a phone, and the email matches an identity from another organizer only, the system shall create a local member that reuses that identity, commit it, and send a registration email without a set-password link. | extracted 2026-10-25 | `svc:132` | `test_resolve_or_register_client_email_known_in_other_organizer_reuses_identity` |
| ENROLL-24 | WHEN staff give names and a phone, and the email is unknown or absent, the system shall register a new member through `users_service.create_member`. | extracted 2026-10-25 | `svc:151` | `test_resolve_or_register_client_new_identity_registers_member`, `test_resolve_or_register_client_without_email_still_registers_local_only_member` |
| ENROLL-25 | IF the registration in ENROLL-24 fails with a `ValueError`, THEN the system shall return 409 with the error text (for example "Podany adres email jest już zajęty"). | extracted 2026-10-25 | `svc:157`, `router:299` | `test_resolve_or_register_client_registration_error_surfaced` |
| ENROLL-26 | WHILE the enrollment is made by staff, the system shall not apply the start-time and horizon checks (ENROLL-13, ENROLL-14). | extracted 2026-10-25 | `svc:290` | `test_create_enrollment_staff_not_bound_by_horizon_or_start_time` |
| ENROLL-27 | WHERE the enrollment is for a guest, the system shall skip the duplicate and overlap checks (ENROLL-15, ENROLL-16). | extracted 2026-10-25 | `svc:295` | — (code only) |
| ENROLL-28 | IF the class is full and `force` is false on a staff enrollment, THEN the system shall return 409 "Zajęcia są pełne (N/N miejsc) — możesz zapisać klienta na listę rezerwową mimo to", where N is the capacity. | extracted 2026-10-25 | `svc:339`, `router:328` | `test_create_enrollment_full_room_blocked_without_force`, `test_create_enrollment_guest_full_blocked_without_force` |
| ENROLL-29 | WHEN the class is full and staff send `force=true`, the system shall create the enrollment with status `waitlist` and position = highest current waitlist position + 1 (1 when the waitlist is empty). Accounts and guests are both allowed. | extracted 2026-10-25 | `svc:342` | `test_create_enrollment_waitlisted_when_room_full_with_force`, `test_create_enrollment_first_on_waitlist_with_force`, `test_create_enrollment_guest_waitlisted_when_full_with_force` |

### Creating an enrollment: common behaviour

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-30 | WHEN the seat-occupying count is below capacity, the system shall create the enrollment with status `confirmed` and no waitlist position. | extracted 2026-10-25 | `svc:313` | `test_create_enrollment_confirmed_when_room_available` |
| ENROLL-31 | WHEN an enrollment is created (confirmed or waitlist), the system shall store a price snapshot from the price list active today: `price_amount` and `is_free`. IF no active price list covers the class type, THEN `price_amount` is null and `is_free` is false ("unpriced"). Later price list changes do not update it. | extracted 2026-10-25 | `svc:309` | `test_create_enrollment_snapshots_price_from_resolved_price_list`, `test_create_enrollment_snapshots_free_class`, `test_create_enrollment_no_active_price_list_leaves_unpriced` |
| ENROLL-32 | WHEN a confirmed enrollment is created for an account, the system shall consume one entry from an eligible pass and link the pass to the enrollment. Eligible = active, valid today, for this class type, with entries left or unlimited; the pass with the earliest `valid_until` wins. An unlimited pass (`remaining_entries` null) is linked but not decremented. Waitlist and guest enrollments never consume a pass. | extracted 2026-10-25 | `svc:226`, `O/services/passes_service.py:248` | `test_create_enrollment_confirmed_consumes_pass_entry`, `test_create_enrollment_confirmed_consumes_unlimited_pass_without_decrementing`, `test_create_enrollment_confirmed_no_eligible_pass_leaves_unconsumed`, `test_create_enrollment_waitlist_does_not_consume_pass`, `test_create_enrollment_guest_does_not_consume_pass` |
| ENROLL-33 | WHEN an enrollment is created with an actor (all HTTP routes pass one), the system shall write an `enrollment_create` activity log entry with the class, trainer, room, location, client name, status and pass. Without an actor, no entry is written. | extracted 2026-10-25 | `svc:362` | `test_create_enrollment_with_actor_logs_entry`, `test_create_enrollment_without_actor_skips_log` |
| ENROLL-34 | WHEN an enrollment is created, the system shall increment the metric `ENROLLMENT_EVENTS_TOTAL` with event `created_confirmed` or `created_waitlist` and channel `self_service` or `staff`. A metric failure does not fail the request (`record_safely`). | extracted 2026-10-25 | `svc:384` | `test_create_enrollment_increments_metric_on_success` |
| ENROLL-35 | WHEN an enrollment is created, the system shall return it with a freshly counted `confirmed_count` for the class (status 201). | extracted 2026-10-25 | `svc:388` | `test_create_enrollment_confirmed_when_room_available` |

### Cancelling an enrollment

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-36 | IF the enrollment does not exist on `PATCH /api/enrollments/{id}/cancel`, THEN the system shall return 404. IF it is already cancelled, THEN the system shall return 409. | extracted 2026-10-25 | `svc:503`, `router:349` | `test_cancel_enrollment_not_found`, `test_cancel_enrollment_already_cancelled` |
| ENROLL-37 | IF the caller is not the enrollment owner and the caller's active role is not admin or reception, THEN the system shall return 403. Trainers and members can cancel only their own enrollments. | extracted 2026-10-25 | `svc:509` | `test_cancel_enrollment_forbidden_for_other_member`, `test_cancel_enrollment_owner_can_cancel`, `test_cancel_enrollment_staff_can_cancel_others` |
| ENROLL-38 | IF the owner (active role not admin or reception) cancels when now ≥ class start − `client_self_cancel_deadline_days` days (default 1, minimum 0), THEN the system shall return 409 "Termin na samodzielne wypisanie się z tych zajęć już minął" and change nothing. | extracted 2026-10-25 | `svc:518`, `svc:396` | `test_cancel_enrollment_owner_blocked_by_deadline`, `test_cancel_enrollment_owner_allowed_outside_deadline`, `test_client_self_cancel_deadline_passed_true_when_within_deadline`, `test_client_self_cancel_deadline_passed_false_when_outside_deadline` |
| ENROLL-39 | WHILE the caller's active role is admin or reception, the system shall allow the cancellation at any time. WHEN that cancellation happens after the client deadline (ENROLL-38), the system shall add a non-blocking `warning` text to the response. | extracted 2026-10-25 | `svc:518`, `router:365` | `test_cancel_enrollment_staff_bypasses_deadline` (warning: code only) |
| ENROLL-40 | WHEN an enrollment is cancelled, the system shall set status `cancelled`, clear the waitlist position, and set `cancelled_at` to the current UTC time. The class status is not checked. | extracted 2026-10-25 | `svc:540` | `test_cancel_enrollment_owner_can_cancel` |
| ENROLL-41 | WHEN a cancelled enrollment had a pass, the system shall return one entry to it (an unlimited pass stays unlimited) and keep the pass link on the enrollment as an audit trail. | extracted 2026-10-25 | `svc:421`, `svc:544` | `test_cancel_enrollment_refunds_pass_entry`, `test_cancel_enrollment_unlimited_pass_refund_stays_none` |
| ENROLL-42 | WHEN a cancelled enrollment had a payment, the system shall create a refund request (reason `enrollment_cancelled`) and shall not change the payment itself. Without a payment, nothing is requested. | extracted 2026-10-25 | `svc:548` | `test_cancel_enrollment_requests_refund_for_paid_enrollment`, `test_cancel_enrollment_without_payment_does_not_touch_payment_table` |
| ENROLL-43 | WHEN a cancelled enrollment occupied a seat (confirmed or attended), the system shall promote the waitlist enrollment with the lowest position to `confirmed`, clear its position, and renumber the remaining waitlist 1, 2, 3, … The capacity is not re-checked. | extracted 2026-10-25 | `svc:433`, `svc:558` | `test_cancel_confirmed_promotes_earliest_waitlisted`, `test_cancel_enrollment_attended_still_promotes_from_waitlist`, `test_cancel_confirmed_no_waitlist_noop` |
| ENROLL-44 | WHEN an account is promoted from the waitlist, the system shall consume an eligible pass as in ENROLL-32, checked for today. A promoted guest consumes nothing. | extracted 2026-10-25 | `svc:462` | `test_cancel_enrollment_promotion_consumes_pass_entry`, `test_cancel_enrollment_promotion_no_eligible_pass_leaves_unconsumed`, `test_cancel_enrollment_promotion_skipped_for_guest` |
| ENROLL-45 | WHEN a waitlist enrollment is cancelled, the system shall not promote anyone and shall not renumber the remaining waitlist positions. | extracted 2026-10-25 | `svc:558` | `test_cancel_waitlisted_does_not_promote_anyone` (asserts no extra query) |
| ENROLL-46 | WHEN an enrollment is cancelled, the system shall always write an `enrollment_cancel` activity log entry (with `was_confirmed`, promoted user ID and name) and increment the metric with event `cancelled`. | extracted 2026-10-25 | `svc:566`, `svc:591` | `test_cancel_enrollment_always_logs_entry` (metric: code only) |
| ENROLL-47 | WHEN a user calls `PATCH /api/enrollments/me/all-organizers/{id}/cancel` with `organizer_code`, the system shall check membership as in ENROLL-18 (403 "Brak dostępu do tej organizacji"; the `member` role is not required), then apply ENROLL-36 to ENROLL-46 in that organizer. The response never has a `warning`. | extracted 2026-10-25 | `router:65` | — (code only) |

### Mark as paid and revert payment

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-48 | IF the enrollment does not exist on `PATCH /api/enrollments/{id}/mark-paid` (staff), THEN the system shall return 404. IF its status is not `confirmed`, THEN the system shall return 409 "Można oznaczyć jako opłacony tylko potwierdzony zapis". The class date is not checked. | extracted 2026-10-25 | `svc:636`, `router:402` | `test_mark_as_paid_not_found`, `test_mark_as_paid_rejects_non_confirmed` |
| ENROLL-49 | WHEN the enrollment already has a payment (paid online before the class), the system shall only set status `attended`, keep the original `paid_at` and `marked_paid_by_user_id`, and create no payment. | extracted 2026-10-25 | `svc:644`, `svc:687` | `test_mark_as_paid_prepaid_online_only_confirms_attendance` |
| ENROLL-50 | WHEN the enrollment already has a pass or is free, the system shall set status `attended`, `paid_at` = now (UTC) and `marked_paid_by_user_id` = the caller, without another charge. | extracted 2026-10-25 | `svc:643`, `svc:686` | `test_mark_as_paid_already_has_pass_just_marks_attended`, `test_mark_as_paid_free_class_just_marks_attended` |
| ENROLL-51 | WHEN the payment is unresolved, the enrollment has an account, and `use_membership_pass` is true (default, also when the body is missing), the system shall look for an eligible pass for today and consume it as in ENROLL-32. | extracted 2026-10-25 | `svc:655`, `router:393` | `test_mark_as_paid_resolves_eligible_pass_now` |
| ENROLL-52 | WHEN the payment is unresolved, the enrollment has an account, and no pass is used (none found, or `use_membership_pass=false`), the system shall create a completed `single_class` payment with amount = price snapshot (0 if unpriced) and method = `payment_method` from the body (cash, card or null), and link it to the enrollment. | extracted 2026-10-25 | `svc:667` | `test_mark_as_paid_no_pass_creates_single_class_payment`, `test_mark_as_paid_use_membership_pass_false_skips_matching_pass`, `test_mark_as_paid_records_chosen_payment_method` (amount 0: code only) |
| ENROLL-53 | WHEN the payment is unresolved and the enrollment is a guest, the system shall create no payment and no pass link, and only set `attended` and `paid_at`. | extracted 2026-10-25 | `svc:683` | `test_mark_as_paid_guest_no_pass_skips_payment_creation` |
| ENROLL-54 | IF `payment_method` is a value other than `cash` or `card`, THEN the system shall return 422. | extracted 2026-10-25 | `schema:176` | — (code only) |
| ENROLL-55 | WHEN an enrollment is marked as paid, the system shall write an `enrollment_mark_paid` activity log entry with `payment_source` (one of `already_resolved`, `membership_pass_existing`, `payment_existing`, `membership_pass_resolved_now`, `single_class_payment`, `guest_unpaid`). | extracted 2026-10-25 | `svc:700` | `test_mark_as_paid_logs_entry` |
| ENROLL-56 | IF the enrollment does not exist on `PATCH /api/enrollments/{id}/revert-payment` (staff), THEN the system shall return 404. IF it is neither `attended` nor `confirmed` with a payment, THEN the system shall return 409. | extracted 2026-10-25 | `svc:752`, `router:424` | `test_revert_payment_not_found`, `test_revert_payment_rejects_non_attended`, `test_revert_payment_unpaid_confirmed_is_still_rejected` |
| ENROLL-57 | WHEN a payment is reverted and the enrollment has a pass, the system shall return one entry to the pass and clear the pass link. This is also done when the pass was consumed at enrollment time, not at mark-paid. | extracted 2026-10-25 | `svc:764` | `test_revert_payment_refunds_membership_pass_and_clears_fk`, `test_revert_payment_unlimited_pass_refund_stays_none` |
| ENROLL-58 | WHEN a payment is reverted and the linked payment is cash or card (no provider reference), the system shall set the payment status to `refunded` and clear the payment link. | extracted 2026-10-25 | `svc:783` | `test_revert_payment_refunds_single_class_payment_and_clears_fk` |
| ENROLL-59 | WHEN a payment is reverted and the linked payment is online (has a provider reference), the system shall create a refund request (reason `payment_reverted`), keep the payment status, and clear the payment link. | extracted 2026-10-25 | `svc:772` | `test_revert_payment_online_payment_requests_refund_instead_of_marking_refunded`, `test_revert_payment_prepaid_online_confirmed_requests_refund` |
| ENROLL-60 | WHEN a payment is reverted, the system shall set status `confirmed`, clear `paid_at` and `marked_paid_by_user_id`, and write an `enrollment_revert_payment` activity log entry with the reverted pass and payment IDs. | extracted 2026-10-25 | `svc:789`, `svc:800` | `test_revert_payment_refunds_membership_pass_and_clears_fk`, `test_revert_payment_free_class_just_resets_status`, `test_revert_payment_logs_entry` |

### Called by other capabilities

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-61 | WHEN a class is cancelled (class schedule capability), the system shall cancel all its active enrollments, clear waitlist positions, return pass entries, create one refund request per payment (reason `class_cancelled`), promote nobody, and return one notice per enrollment (email, refund requested, pass entry returned). It does not commit; the caller does. | extracted 2026-10-25 | `svc:1030` | `test_cancel_enrollments_for_cancelled_schedule` |
| ENROLL-62 | WHEN a cancellation preview is requested, the system shall count seat-occupying enrollments, waitlist enrollments, active enrollments with a payment, and active enrollments with a pass. | extracted 2026-10-25 | `svc:1020` | `test_schedule_cancellation_preview_counts` |
| ENROLL-63 | WHEN an admin calls `POST /api/enrollments/guests/{id}/anonymize`, the system shall erase the guest data of that one enrollment (details in the personal data erasure capability). IF the enrollment does not exist or has an account, THEN 404. IF erasure is blocked or warnings are not acknowledged, THEN 409. | extracted 2026-10-25 | `router:254`, `svc:955` | — (code only; erasure logic tested in the erasure capability) |

### Database rules

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| ENROLL-64 | The database shall reject an enrollment that has neither `user_id` nor both guest names (`ck_enrollments_user_or_guest`). | extracted 2026-10-25 | `O/models/enrollment.py:28` | — (code only) |
| ENROLL-65 | The database shall reject two `waitlist` enrollments on the same class with the same position (partial unique index `uq_enrollments_waitlist_position`). | extracted 2026-10-25 | `binturo-organizers/backend/alembic/versions/0028_reservation_and_season_data_integrity.py:53` | — (code only) |

## Invariants and concurrency

No row lock (`with_for_update`), advisory lock or conditional update was found in this capability (search in `app/` and `alembic/versions/`). All tests use a mocked session, so no parallel test exists.

| Invariant | Enforced by | Test |
|---|---|---|
| Seat-occupying enrollments ≤ capacity (unless staff used `force`, which goes to the waitlist) | Count, then insert, in code (`svc:313`). **none found** in the database | none |
| At most one active enrollment per client and class | Select, then insert, in code (`svc:190`). **none found** in the database | none |
| A client has no two active enrollments on overlapping classes | Select, then insert, in code (`svc:204`). **none found** in the database | none |
| Waitlist positions are unique per class | `MAX + 1` in code (`svc:342`) + partial unique index (ENROLL-65). A collision gives an unhandled `IntegrityError` → 500 (`O/main.py:111`) | none |
| A cancellation happens once (one pass refund, one promotion, one refund request) | Status read, then write, in code (`svc:506`). **none found** in the database | none |
| A pass entry is consumed or returned once per enrollment | Python read-modify-write `remaining_entries -= 1 / += 1` (`svc:244`, `svc:430`). **none found** (no atomic update) | none |
| Mark as paid creates at most one payment per enrollment | Status read, then write, in code (`svc:639`). **none found** | none |
| An enrollment has an account or both guest names | Check constraint (ENROLL-64) | none |

## Edge cases (current)

- Empty or missing input: ENROLL-10 (short `q`), ENROLL-19 (no client data), ENROLL-21 (no phone → guest), ENROLL-51 (missing body → defaults).
- Boundaries: ENROLL-13 (start = now is "started"), ENROLL-14 (start = horizon end is allowed), ENROLL-16 (touching classes do not overlap), ENROLL-38 (now = cutoff is blocked), ENROLL-29 (first waitlist position is 1).
- Text: ENROLL-10 (`%` and `_` literal, case-insensitive).
- Money: ENROLL-31 (unpriced), ENROLL-52 (unpriced → payment amount 0).
- Duplicates and repeats (sequential): ENROLL-15, ENROLL-36 (cancel twice), ENROLL-48 (mark paid twice), ENROLL-56 (revert unpaid).
- Permissions and state: ENROLL-6, ENROLL-11, ENROLL-12, ENROLL-18, ENROLL-20, ENROLL-37, ENROLL-47.
- Repeats in parallel: not handled, see the race questions below.

## Open questions

Suspected bugs (documented as-is):
- [ ] **Waitlist renumbering can fail on promotion (ASSUMED, not run).** ENROLL-43 changes several waitlist positions in one flush. The unique index (ENROLL-65) is checked per row. If SQLAlchemy writes "position 2 → 1" before the promoted row leaves the waitlist, Postgres rejects it and the cancel returns 500. This is likely with 2 or more people on the waitlist. Needs a real-database test.
- [ ] **Account created even when the enrollment fails.** In ENROLL-23 and ENROLL-24 the new member is committed (and an email sent) before capacity and overlap are checked. If the class is full, staff get 409 but the account stays.
- [ ] **Overlap message wording in self-service.** The service always builds "Klient ma już zapis na …" (third person). The client-facing fallback "Masz już zapis …" (`router:142`) is never used, so clients see staff wording.
- [ ] **Simplified mode is not applied consistently.** A trainer passes `require_staff` in simplified mode (ENROLL-19), but cancellation (ENROLL-37) and the warning (ENROLL-39) check for admin or reception only. In simplified mode a trainer can enroll anyone but cannot cancel other clients' enrollments.
- [ ] **Deactivated members can be enrolled by staff** (ENROLL-20 does not check `is_active`). Intended?
- [ ] **No length limit on guest names in the request.** The columns are `String(100)` (`O/models/enrollment.py:52`), but `EnrollmentCreate` has no `max_length`. A longer name gives a database error (500). The email is a plain `str`, not validated as an email.
- [ ] **Unmapped error code in self-service.** `_raise_own_enrollment_error` has no branch for `USER_NOT_FOUND` (`router:124`). If it ever happens, the endpoint returns `None` and fails response validation (500). The comment at `router:188` says this is unreachable on `POST /me`.

Race risks (shared state with no mechanism):
- [ ] Two parallel enrollments on the last seat can both be confirmed (overbooking).
- [ ] A double click can create two active enrollments for the same client and class.
- [ ] Two parallel cancellations of the same enrollment can return the pass entry twice, promote two people, and create two refund requests.
- [ ] Two parallel pass consumptions can lose one decrement (pass rules belong to the passes capability, but this capability writes them).
- [ ] Two parallel "mark as paid" calls can create two payments.

Behaviour to confirm:
- [ ] **Time zone.** "Now" is the server's local clock labelled UTC (`svc:173`, `svc:417`). This is correct only if the server runs in the organizer's zone (the source doc says Europe/Warsaw). All organizers share one server zone. DST changes are not handled specially. Is a single zone for all organizers a fixed business rule?
- [ ] **Cross-organizer endpoints skip the subscription lock.** ENROLL-3, ENROLL-18 and ENROLL-47 use only the global token, not `require_roles` or `require_authenticated_and_unlocked`. A client can enroll in an organizer whose subscription has expired. Intended?
- [ ] **ENROLL-18 checks the `member` role in all roles, ENROLL-11 checks the active role.** A user whose active role is admin can self-enroll through the cross-organizer endpoint but not through `POST /me`.
- [ ] **Promotion ignores capacity and overlap.** ENROLL-43 promotes even if the class is still at or above capacity, and does not re-check ENROLL-16 for the promoted client. No notification to the promoted client was found in this capability.
- [ ] **Waitlist gaps.** ENROLL-45 leaves gaps (1, 3) after a waitlist cancellation. Ordering still works. Intended?
- [ ] **Cancellation after the class.** Staff can cancel an attended enrollment on a past class (ENROLL-40 does not check the class). This creates a refund request and promotes someone on a finished class.
- [ ] **Email failure after commit.** In ENROLL-23 the account is committed before the email is sent. What `send_account_registered_email` does on failure was not read.
- [ ] **Roster order inside the confirmed group** is not defined (ENROLL-7). Confirmed and attended rows come in database order.

Conflicts between code and the source documentation (`binturo-organizers/backend/CLAUDE.md`):
- [ ] The doc says revert payment works only for `attended` (`CLAUDE.md:2013`). The code also allows `confirmed` with an online prepayment (ENROLL-56). Readers of the doc expect a 409 that does not happen.
- [ ] The doc says mark as paid always sets `paid_at` and the marker (`CLAUDE.md:1952`). The code keeps the original values for online prepayments (ENROLL-49). The audit shows the client, not the staff member, as marker.
- [ ] The doc says the guest search covers non-cancelled enrollments only (`CLAUDE.md:1911`). The code has `include_cancelled` (ENROLL-10).
- [ ] The doc names the create response `EnrollmentEnrollResponse` (`CLAUDE.md:1672`). The code has `EnrollmentCreateResponse` (`schema:115`). The shape `{enrollment}` is the same.
- [ ] The doc lists `GET /enrollments/schedule/{id}` as "staff + trainer" (`CLAUDE.md:1670`). The code uses `require_authenticated_and_unlocked` and a manual role check (ENROLL-6), so simplified mode does not apply there.
- [ ] `get_current_global_user_id` says it is used only by three endpoints, including `GET /reservations/me/all` (`O/auth/dependencies.py:45`). It is also used by the two cross-organizer write endpoints (ENROLL-18, ENROLL-47), and the path is now `/enrollments`.

## Contracts
- HTTP routes (prefix `/api/enrollments`, `router:35`): `GET /me`, `GET /me/all`, `POST /me`, `POST /me/all-organizers`, `PATCH /me/all-organizers/{id}/cancel`, `GET ?user_id=`, `GET /schedule/{schedule_id}`, `GET /guests?q=&include_cancelled=`, `POST /guests/{id}/anonymize`, `POST ""`, `PATCH /{id}/cancel`, `PATCH /{id}/mark-paid`, `PATCH /{id}/revert-payment`.
- Request and response schemas: `binturo-organizers/backend/app/schemas/enrollment.py`. No OpenAPI file is checked in (FastAPI generates it at runtime).
- Error codes: `binturo-organizers/backend/app/services/enrollment_errors.py`.
- Data: table `enrollments` (`O/models/enrollment.py`), migrations `0013`, `0028`, `0029`, `0049` in `binturo-organizers/backend/alembic/versions/`.
- Service functions used by other capabilities: `cancel_enrollments_for_cancelled_schedule`, `schedule_cancellation_preview`, `OCCUPIED_SEAT_STATUSES`, `get_guest_enrollment`.
- Activity log actions: `enrollment_create`, `enrollment_cancel`, `enrollment_mark_paid`, `enrollment_revert_payment`. Metric: `ENROLLMENT_EVENTS_TOTAL` (`O/metrics.py`).

## Decisions
- none recorded yet (run `/spec-extract D:\projects\reservations adr`).

## History
| Spec | Change |
|---|---|
| extracted 2026-10-25 | Documented from existing code with `/spec-extract` |
