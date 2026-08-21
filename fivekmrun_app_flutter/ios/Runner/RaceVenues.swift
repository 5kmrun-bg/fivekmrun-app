import Foundation

/// Race venues used for the Wallet pass's "relevant location" trigger (#212).
///
/// Every 5kmRun Saturday event runs at the same time slot (9:00–12:00) but at
/// a different place each week, and Apple's pass `locations` array applies to
/// the *whole* pass rather than to individual `relevantDates` entries — so
/// there is no way to pair "this Saturday" with "this Saturday's venue"
/// specifically. The pass ends up relevant on any Saturday morning AND near
/// *any* of the venues listed here. That's an Apple-side limitation, not a
/// bug — see #212 for the full writeup.
///
/// To add a venue: add one more `RaceVenue(...)` line below. Apple allows at
/// most 10 locations per pass (`Pass.locations`), so keep this list capped at
/// 10 entries.
struct RaceVenue {
    let name: String
    let latitude: Double
    let longitude: Double
}

let raceVenues: [RaceVenue] = [
    // Южен парк (South Park), Sofia — start-line coordinates from the
    // route's own page: https://5kmrun.bg/route/94
    RaceVenue(name: "Южен парк, София", latitude: 42.672028, longitude: 23.307750),

    // Западен парк (West Park), Sofia — https://5kmrun.bg/route/95
    RaceVenue(name: "Западен парк, София", latitude: 42.708978, longitude: 23.275349),

    // гр. Пловдив, Гребна база (Гребен канал 2) — https://5kmrun.bg/route/99
    RaceVenue(name: "Гребен канал 2, Пловдив", latitude: 42.146111, longitude: 24.713056),

    // Парк Лаута, Пловдив — https://5kmrun.bg/route/100 (site page has no
    // text coordinates; taken from its own Google Maps pin instead).
    // NOTE: Plovdiv has two routes listed on 5kmrun.bg/routes/5km (this one
    // and Гребен канал 2 above) — both are included since it wasn't
    // specified which is "the" regular run; remove whichever doesn't apply.
    RaceVenue(name: "Парк Лаута, Пловдив", latitude: 42.139019, longitude: 24.779428),

    // гр. Бургас, Морска градина (Sea Garden) — https://5kmrun.bg/route/97
    RaceVenue(name: "Морска градина, Бургас", latitude: 42.500944, longitude: 27.480722),

    // гр. Варна, Морска градина (Sea Garden) — https://5kmrun.bg/route/96
    RaceVenue(name: "Морска градина, Варна", latitude: 43.205944, longitude: 27.926444),

    // Add more venues here, one per line, following the same shape:
    // RaceVenue(name: "<venue name>", latitude: <lat>, longitude: <lon>),
]
