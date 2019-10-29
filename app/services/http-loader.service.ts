import { Injectable } from "@angular/core";
import { BehaviorSubject, Observable } from "rxjs";
import { map } from "rxjs/operators";

@Injectable({
    providedIn: "root"
})
export class HttpLoaderService {
    currentRequests$: BehaviorSubject<number>;
    isLoading$: Observable<boolean>;

    constructor() {
        this.currentRequests$ = new BehaviorSubject(0);
        this.isLoading$ = this.currentRequests$.pipe(map(requests => requests > 0));
    }

    public onRequestStart() {
        setTimeout(() => {
            this.currentRequests$.next(this.currentRequests$.value + 1);
        }, 10);
    }

    public onRequestEnd() {
        setTimeout(() => {
            this.currentRequests$.next(this.currentRequests$.value - 1);
        }, 10);
    }
}
