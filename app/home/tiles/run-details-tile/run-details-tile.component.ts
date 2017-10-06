import { Component, OnInit, Input } from "@angular/core";
import { Run } from "../../../models";

@Component({ 
    selector: "run-details-tile",
    moduleId: module.id,
    templateUrl: "./run-details-tile.component.html"
})
export class RunDetailsTileComponent implements OnInit {
    @Input() run: Run;
    @Input() title: string;
    @Input() col: number;
    @Input() row: number; 
    
    ngOnInit(): void {
    }
}