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

    // Add more venues here, one per line, following the same shape:
    // RaceVenue(name: "<venue name>", latitude: <lat>, longitude: <lon>),
]
