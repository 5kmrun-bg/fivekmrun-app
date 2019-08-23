import { Component, OnInit} from "@angular/core";
import * as utils from "tns-core-modules/utils/utils";
import * as firebase from "nativescript-plugin-firebase";

@Component({
    selector: "Donation",
    moduleId: module.id,
    templateUrl: "./donation.component.html"
})
export class DonationComponent implements OnInit {
    ngOnInit(): void {
        firebase.analytics.logEvent({ key: "page_donation_opened" });
    }

    initiateDonation(): void {
        console.log("log donation");
        firebase.analytics.logEvent({ key: "button_donation_clicked" });
        utils.openUrl("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6B7VDX7UW7JKJ&source=url");
    }
}