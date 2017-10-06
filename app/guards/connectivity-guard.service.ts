import { Injectable } from "@angular/core";
import { Router, CanActivate } from "@angular/router";
import * as connectivity from "tns-core-modules/connectivity";

@Injectable()
export class ConnectivityGuard implements CanActivate {
    constructor(private router: Router) {
    }
    
    canActivate(): boolean {
        console.log("Checking connectivity ... " + connectivity.getConnectionType());

        if (connectivity.getConnectionType() == connectivity.connectionType.none) {
            this.router.navigate(["/errors/no-internet"]);
            return false;
        }

        return true;
    }
}