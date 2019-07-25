import { Component, OnInit } from "@angular/core";
import { RunService } from "../services";
import { Run } from "../models";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "Runs",
    moduleId: module.id,
    templateUrl: "./runs.component.html"
})
export class RunsComponent implements OnInit {
    runs: Observable<Run[]>;

    constructor(private runService: RunService) {}

    ngOnInit(): void {
        this.runs = this.runService.getByCurrentUser();
    }
}