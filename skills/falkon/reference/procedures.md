# Callable procedures

The output of `falkon procedures` for `falkon 0.1.0`, as a table. `falkon procedures` prints the current list offline, and `falkon procedures <procedure>` shows one entry with an example request and a minimal one.

Access values:

- `public`: needs no session; the token is not required.
- `admin token ok (<roles>)`: the roles the server accepts. An admin token passes.
- `guest flow (owner or admin: any application)`: calls the parents' application form makes. An admin token can act on any application.
- `guest flow (the token owner's own applications)`: works only on the admin's own applications. `ListMyCampApplications` lists only those, and `CreateCampApplication` creates one owned by the admin. Use the `StaffService` calls to see other families' applications.
- `browser session only`: the server refuses API tokens. Do not call these.
- `public (browser WebAuthn ceremony)`: part of a passkey sign-in in a browser. Not useful from the CLI.

`/api/prihlaskaPDF` answers with a PDF, not JSON, so `falkon call` cannot print it.

| Procedure | Request | Response | Access |
| --- | --- | --- | --- |
| `ApplicantService/CreateApplicant` | CreateApplicantRequest | CreateApplicantResponse | guest flow (owner or admin: any application) |
| `ApplicantService/GetApplicant` | GetApplicantRequest | GetApplicantResponse | guest flow (owner or admin: any application) |
| `ApplicantService/UpdateApplicant` | UpdateApplicantRequest | UpdateApplicantResponse | guest flow (owner or admin: any application) |
| `ApplicantService/DeleteApplicant` | DeleteApplicantRequest | DeleteApplicantResponse | guest flow (owner or admin: any application) |
| `AuthService/LoginStaff` | LoginStaffRequest | AuthSession | public |
| `AuthService/RegisterGuest` | RegisterGuestRequest | AuthSession | public |
| `AuthService/ValidateSession` | ValidateSessionRequest | ValidateSessionResponse | public |
| `AuthService/GetInstructorSetup` | GetInstructorSetupRequest | GetInstructorSetupResponse | public |
| `AuthService/CompleteInstructorSetup` | CompleteInstructorSetupRequest | CompleteInstructorSetupResponse | public |
| `AuthService/Logout` | LogoutRequest | LogoutResponse | browser session only |
| `CampApplicationService/CreateCampApplication` | CreateCampApplicationRequest | CreateCampApplicationResponse | guest flow (the token owner's own applications) |
| `CampApplicationService/GetMyCampApplication` | GetMyCampApplicationRequest | GetMyCampApplicationResponse | guest flow (owner or admin: any application) |
| `CampApplicationService/ListMyCampApplications` | ListMyCampApplicationsRequest | ListMyCampApplicationsResponse | guest flow (the token owner's own applications) |
| `CampApplicationService/UpdateCampApplication` | UpdateCampApplicationRequest | UpdateCampApplicationResponse | guest flow (owner or admin: any application) |
| `CampApplicationService/CompleteCampApplication` | CompleteCampApplicationRequest | CompleteCampApplicationResponse | guest flow (owner or admin: any application) |
| `CampApplicationService/CancelCampApplication` | CancelCampApplicationRequest | CancelCampApplicationResponse | guest flow (owner or admin: any application) |
| `CampApplicationService/DeleteCampApplication` | DeleteCampApplicationRequest | DeleteCampApplicationResponse | guest flow (owner or admin: any application) |
| `ContactPersonService/CreateContactPerson` | CreateContactPersonRequest | CreateContactPersonResponse | guest flow (owner or admin: any application) |
| `ContactPersonService/GetContactPerson` | GetContactPersonRequest | GetContactPersonResponse | guest flow (owner or admin: any application) |
| `ContactPersonService/UpdateContactPerson` | UpdateContactPersonRequest | UpdateContactPersonResponse | guest flow (owner or admin: any application) |
| `ContactPersonService/DeleteContactPerson` | DeleteContactPersonRequest | DeleteContactPersonResponse | guest flow (owner or admin: any application) |
| `DashboardService/GetDashboardData` | GetDashboardDataRequest | GetDashboardDataResponse | admin token ok (admin) |
| `DashboardService/GetDashboardContactExport` | GetDashboardContactExportRequest | GetDashboardContactExportResponse | admin token ok (admin) |
| `DocumentService/GenerateCampApplicationPdf` | GenerateCampApplicationPdfRequest | GenerateCampApplicationPdfResponse | admin token ok (owner or admin) |
| `DocumentService/GenerateEmptyCampApplicationPdf` | GenerateEmptyCampApplicationPdfRequest | GenerateEmptyCampApplicationPdfResponse | admin token ok (admin) |
| `StaffService/ListCampApplicationsAccounting` | ListCampApplicationsAccountingRequest | ListCampApplicationsAccountingResponse | admin token ok (accountant, admin) |
| `StaffService/UpdateCampApplicationPaymentStatus` | UpdateCampApplicationPaymentStatusRequest | UpdateCampApplicationPaymentStatusResponse | admin token ok (accountant, admin) |
| `StaffService/UpdateCampApplicationPaymentStatusBulk` | UpdateCampApplicationPaymentStatusBulkRequest | UpdateCampApplicationPaymentStatusBulkResponse | admin token ok (accountant, admin) |
| `StaffService/SendEmailPaid` | SendEmailPaidRequest | SendEmailPaidResponse | admin token ok (accountant, admin) |
| `StaffService/CancelApplicantTerm` | CancelApplicantTermRequest | CancelApplicantTermResponse | admin token ok (admin) |
| `StaffService/RestoreApplicantTerm` | RestoreApplicantTermRequest | RestoreApplicantTermResponse | admin token ok (admin) |
| `StaffService/CancelApplicantTerms` | CancelApplicantTermsRequest | CancelApplicantTermsResponse | admin token ok (admin) |
| `StaffService/GetApplicantInfo` | GetApplicantInfoRequest | GetApplicantInfoResponse | admin token ok (manager, admin) |
| `StaffService/ListParticipantRoster` | ListParticipantRosterRequest | ListParticipantRosterResponse | admin token ok (admin) |
| `StaffService/ListAttendance` | ListAttendanceRequest | ListAttendanceResponse | admin token ok (admin, instructor) |
| `StaffService/ListAttendanceHistory` | ListAttendanceHistoryRequest | ListAttendanceHistoryResponse | admin token ok (admin, instructor) |
| `StaffService/UpdateAttendanceDay` | UpdateAttendanceDayRequest | UpdateAttendanceDayResponse | admin token ok (admin, instructor) |
| `StaffService/UpdateAttendanceTermSettings` | UpdateAttendanceTermSettingsRequest | UpdateAttendanceTermSettingsResponse | admin token ok (admin) |
| `StaffService/UpdateAttendanceNote` | UpdateAttendanceNoteRequest | UpdateAttendanceNoteResponse | admin token ok (admin, instructor) |
| `StaffService/UpdateAttendancePamphlet` | UpdateAttendancePamphletRequest | UpdateAttendancePamphletResponse | admin token ok (admin, instructor) |
| `StaffService/UpdateAttendanceNight` | UpdateAttendanceNightRequest | UpdateAttendanceNightResponse | admin token ok (admin, instructor) |
| `StaffService/GetPushConfig` | GetPushConfigRequest | GetPushConfigResponse | admin token ok (admin, instructor) |
| `StaffService/GetPushSubscriptionStatus` | GetPushSubscriptionStatusRequest | GetPushSubscriptionStatusResponse | admin token ok (admin, instructor) |
| `StaffService/UpsertPushSubscription` | UpsertPushSubscriptionRequest | UpsertPushSubscriptionResponse | browser session only |
| `StaffService/DeletePushSubscription` | DeletePushSubscriptionRequest | DeletePushSubscriptionResponse | admin token ok (admin, instructor) |
| `StaffService/ListInstructorAccess` | ListInstructorAccessRequest | ListInstructorAccessResponse | admin token ok (admin) |
| `StaffService/CreateInstructorSetupToken` | CreateInstructorSetupTokenRequest | CreateInstructorSetupTokenResponse | admin token ok (admin) |
| `StaffService/GrantInstructorTermAccess` | GrantInstructorTermAccessRequest | GrantInstructorTermAccessResponse | admin token ok (admin) |
| `StaffService/RevokeInstructorTermAccess` | RevokeInstructorTermAccessRequest | RevokeInstructorTermAccessResponse | admin token ok (admin) |
| `TermService/ListTerms` | ListTermsRequest | ListTermsResponse | public |
| `AdminTermService/ListTerms` | AdminTermServiceListTermsRequest | AdminTermServiceListTermsResponse | admin token ok (admin) |
| `AdminTermService/CreateTerm` | CreateTermRequest | CreateTermResponse | admin token ok (admin) |
| `AdminTermService/UpdateTerm` | UpdateTermRequest | UpdateTermResponse | admin token ok (admin) |
| `AdminTermService/ActivateTerm` | ActivateTermRequest | ActivateTermResponse | admin token ok (admin) |
| `AdminTermService/DeactivateTerm` | DeactivateTermRequest | DeactivateTermResponse | admin token ok (admin) |
| `AdminTermService/DeleteDraftTerm` | DeleteDraftTermRequest | DeleteDraftTermResponse | admin token ok (admin) |
| `AdminTermService/ListTermActivity` | ListTermActivityRequest | ListTermActivityResponse | admin token ok (admin) |
| `/api/whoami` | {} | WhoAmIResponse | admin token ok (any signed-in caller) |
| `/api/api-tokens/list` | {} | ListApiTokensResponse | admin token ok (admin) |
| `/api/api-tokens/create` | CreateApiTokenRequest | CreateApiTokenResponse | admin token ok (admin) |
| `/api/api-tokens/revoke` | RevokeApiTokenRequest | ApiTokenInfo | admin token ok (admin) |
| `/api/passkey/list` | {} | ListPasskeysResponse | admin token ok (admin, accountant, instructor; own passkeys) |
| `/api/passkey/rename` | RenamePasskeyRequest | PasskeyInfo | admin token ok (admin, accountant, instructor; own passkeys) |
| `/api/passkey/delete` | DeletePasskeyRequest | ListPasskeysResponse | admin token ok (admin, accountant, instructor; own passkeys) |
| `/api/passkey/registration/start` | {} | PasskeyCeremony | browser session only |
| `/api/passkey/registration/finish` | FinishPasskeyRegistrationRequest | PasskeyInfo | browser session only |
| `/api/passkey/login/start` | {} | PasskeyCeremony | public (browser WebAuthn ceremony) |
| `/api/passkey/login/finish` | FinishPasskeyLoginRequest | AuthSession | public (browser WebAuthn ceremony) |
| `/api/staff-invite/get` | StaffInviteTokenRequest | GetStaffInviteResponse | public |
| `/api/staff-invite/start` | StaffInviteTokenRequest | PasskeyCeremony | public (browser WebAuthn ceremony) |
| `/api/staff-invite/finish` | FinishStaffInviteRequest | AuthSession | public (browser WebAuthn ceremony) |
| `/api/prihlaskaPDF` | {campApplicationUUID} | application/pdf (not JSON) | admin token ok (owner or admin) |
