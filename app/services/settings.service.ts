import { Injectable } from "@angular/core";
import {
    getBoolean,
    setBoolean } from "tns-core-modules/application-settings";

@Injectable()
export class SettingsService {
    private NOTIFICATIONS_KEY = "KEY_NOTIFICATIONS";


    constructor() { }

    set NotificationsAllowed(value: boolean) {
        setBoolean(this.NOTIFICATIONS_KEY, value);
    }

    get NotificationsAllowed(): boolean {
        return getBoolean(this.NOTIFICATIONS_KEY, false);
    }
}
