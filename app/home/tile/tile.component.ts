import { Component, OnInit, ViewChild, Input } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui-pro/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui-pro/sidedrawer/angular";
import { Observable } from "rxjs/Observable";
import { Run } from "../../models";

@Component({ 
    selector: "tile",
    moduleId: module.id,
    templateUrl: "./tile.component.html"
})
export class TileComponent implements OnInit {
    @Input() run: Run;
    @Input() title: string;
    @Input() col: number;
    @Input() row: number; 
    
    ngOnInit(): void {

    }
}