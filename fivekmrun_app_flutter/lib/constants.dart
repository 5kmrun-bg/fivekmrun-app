const baseUrl = "http://old.5kmrun.bg/5km/";
const pastEventsUrl = baseUrl + "calendar-a.php";
const futureEventsUrl = baseUrl + "calendar.php";
const runsUrl = baseUrl + "stat.php?id=";
const resultsUrl = baseUrl + "results.php?event=";
const userUrl = baseUrl + "usr.php?id=";

const endpointBaseUrl = "https://5kmrun.bg/api/5kmrun/";
const userEndpointUrl = endpointBaseUrl + "user/";
const offlineChartEndpointUrl = "https://5kmrun.bg/api/selfie/ofc/";


const String key_userId = "5kmrun_UserID";
const String key_token = "5kmrun_Token";
const String key_tokenTimestamp = "5kmrun_Token_Created";
const int tokenExpiryDays = 30;

const int stravaFilterMinDistance = 4900;
const int stravaFilterMaxDistance = 5300;