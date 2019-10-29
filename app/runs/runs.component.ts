import { Component, OnInit } from "@angular/core";
import { Observable } from "rxjs";
import { Run } from "../models";
import { RunService } from "../services";

@Component({
    selector: "Runs",
    moduleId: module.id,
    templateUrl: "./runs.component.html"
})
export class RunsComponent implements OnInit {
    runs$: Observable<Run[]>;

    constructor(private runService: RunService) { }

    ngOnInit(): void {
        this.runs$ = this.runService.getByCurrentUser();
    }
}
