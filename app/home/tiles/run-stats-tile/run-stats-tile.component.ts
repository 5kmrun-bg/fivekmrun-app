import { Component, OnInit, Input } from "@angular/core";
import { Run } from "../../../models";
import { Observable } from "rxjs/Observable";

@Component({ 
    selector: "run-stats-tile",
    moduleId: module.id,
    templateUrl: "./run-stats-tile.component.html"
})
export class RunStatsTileComponent implements OnInit {
    @Input() runs$: Observable<Run[]>;
    
    ngOnInit(): void {
    }
}