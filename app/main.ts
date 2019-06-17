// this import should be first in order to load some required settings (like globals and reflect-metadata)
import { platformNativeScriptDynamic } from "nativescript-angular/platform";
import { AppOptions } from "nativescript-angular/platform-common";
import { AppModule } from "./app.module";
import "./livesync-navigation";

import * as elementRegistryModule from 'nativescript-angular/element-registry';
elementRegistryModule.registerElement("CardView", () => require("nativescript-cardview").CardView);

let options: AppOptions = {};

if (module["hot"]) {
    options.hmrOptions = {
        moduleTypeFactory: () => AppModule,
        livesyncCallback: (platformReboot) => {
            setTimeout(platformReboot, 0);
        },
    }

    // Path to your app module.
	// You might have to change it if your module is in a different place.
    module['hot'].accept(["./app.module"], () => {
        // Currently the context is needed only for application style modules.
        const moduleContext = {};
        global["hmrRefresh"](moduleContext);
    });
}

platformNativeScriptDynamic(options).bootstrapModule(AppModule);
