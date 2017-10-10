// this import should be first in order to load some required settings (like globals and reflect-metadata)
import { platformNativeScriptDynamic } from "nativescript-angular/platform";
import * as elementRegistryModule from 'nativescript-angular/element-registry';

import { AppModule } from "./app.module";

elementRegistryModule.registerElement("CardView", () => require("nativescript-cardview").CardView);

platformNativeScriptDynamic().bootstrapModule(AppModule);
