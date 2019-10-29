import { Component, Input, OnInit } from "@angular/core";
import { registerElement } from "nativescript-angular/element-registry";
import { Observable } from "rxjs";
import { tap } from "rxjs/operators";
import { ContentView } from "tns-core-modules/ui/page/page";
import { User } from "~/models";

registerElement("total-distance-tile", () => { return ContentView });
@Component({ 
    selector: "total-distance-tile",
    moduleId: module.id,
    templateUrl: "./total-distance-tile.component.html"
})
export class TotalDistanceTileComponent implements OnInit {
    @Input() currentUser$: Observable<User>;
    nextMilestone: number = 1250;
    currentDistance: number = 0;

    ngOnInit(): void {
        this.currentUser$.pipe(tap(u => this.currentDistance = u.totalKmRan)).subscribe();
    }
}