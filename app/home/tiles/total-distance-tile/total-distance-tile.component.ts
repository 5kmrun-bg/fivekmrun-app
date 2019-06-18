import { Component, OnInit, Input } from "@angular/core";
import { registerElement } from "nativescript-angular/element-registry";
import { ContentView } from "tns-core-modules/ui/page/page";

registerElement("total-distance-tile", () => { return ContentView })
@Component({ 
    selector: "total-distance-tile",
    moduleId: module.id,
    templateUrl: "./total-distance-tile.component.html"
})
export class TotalDistanceTileComponent implements OnInit {
    @Input() distance: string;
    
    ngOnInit(): void {
    }
}