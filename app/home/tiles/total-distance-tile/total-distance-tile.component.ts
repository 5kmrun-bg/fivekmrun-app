import { Component, OnInit, Input } from "@angular/core";
import { registerElement } from "nativescript-angular/element-registry";
import { ContentView } from "tns-core-modules/ui/page/page";
import { Observable } from "rxjs/Observable";
import { User } from "~/models";

registerElement("total-distance-tile", () => { return ContentView })
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
        this.currentUser$.do(u => this.currentDistance = u.totalKmRan).subscribe();
    }
}