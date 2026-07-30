const pastEventsUrl = "https://5kmrun.bg/api/5kmrun/results";
const futureEventsUrl = "https://5kmrun.bg/api/5kmrun/events";
const resultEventsUrl = "https://5kmrun.bg/api/5kmrun/result/";
const xlFutureEventsUrl = "https://5kmrun.bg/api/xlrun/events";
const xlPastEventsUrl = "https://5kmrun.bg/api/xlrun/results";
const xlResultEventsUrl = "https://5kmrun.bg/api/xlrun/result/";
const kidsFutureEventsUrl = "https://5kmrun.bg/api/kidsrun/events";
const kidsPastEventsUrl = "https://5kmrun.bg/api/kidsrun/results";
const kidsResultEventsUrl = "https://5kmrun.bg/api/kidsrun/result/";
const wrapUrl = "https://wrapped.5kmrun.bg/";

const endpointBaseUrl = "https://5kmrun.bg/api/5kmrun/";
const userEndpointUrl = "https://5kmrun.bg/api/selfie/user/";
const runsEndpointUrl = endpointBaseUrl + "user/";
const offlineChartEndpointUrl = "https://5kmrun.bg/api/selfie/ofc/";
const xlUserEndpointUrl = "https://5kmrun.bg/api/xlrun/user/";

const String key_userId = "5kmrun_UserID";
const String key_token = "5kmrun_Token";
const String key_tokenTimestamp = "5kmrun_Token_Created";
const int tokenExpiryDays = 30;
const String key_lastSeenWhatsNewVersion = "5kmrun_LastSeenWhatsNewVersion";

// Multi-profile storage (#184). key_userId/key_token/key_tokenTimestamp above
// are the pre-multi-profile single-account keys — loadFromLocalStore()
// migrates them into a one-profile list under key_profiles the first time it
// finds no profiles list yet, then leaves them alone (harmless dead keys).
const String key_profiles = "5kmrun_Profiles";
const String key_activeProfileId = "5kmrun_ActiveProfileId";
const int maxProfiles = 5;

const int stravaFilterMinDistance = 4900;
const int stravaFilterMaxDistance = 5300;
