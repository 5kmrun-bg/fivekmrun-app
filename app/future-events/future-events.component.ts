import { Component, OnInit } from "@angular/core";
import { EventService } from "../services";
import { Event } from "../models";
import { Observable } from "rxjs";
import { isIOS } from 'tns-core-modules/platform';
declare var UITableViewCellSelectionStyle;

@Component({
    selector: "FutureEvents",
    moduleId: module.id,
    templateUrl: "./future-events.component.html"
})
export class FutureEventsComponent implements OnInit {

    events$: Observable<Event[]>;

    constructor(private eventService: EventService) {}

    ngOnInit(): void {
        this.events$ = this.eventService.getAllFutureEvents();
    }

    onItemLoading(args) {
        if (isIOS) {
          const iosCell = args.ios;
          iosCell.selectionStyle = UITableViewCellSelectionStyle.None;
        }
      }
}
