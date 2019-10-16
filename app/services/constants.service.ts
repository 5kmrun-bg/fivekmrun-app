import { Injectable } from "@angular/core";

@Injectable({
    providedIn: 'root',
})
export class ConstantsService {
    public baseUrl: string = "http://old.5kmrun.bg/5km/";
    public pastEventsUrl: string = this.baseUrl + "calendar-a.php";
    public futureEventsUrl: string = this.baseUrl + "calendar.php";
    public runsUrl: string = this.baseUrl + "stat.php?id=";
    public resultsUrl: string = this.baseUrl + "results.php?event=";
    public userUrl: string = this.baseUrl + "usr.php?id=";
}