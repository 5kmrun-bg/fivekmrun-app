import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest, HttpResponse } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable, BehaviorSubject } from "rxjs";
import { tap, map } from "rxjs/operators";

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
