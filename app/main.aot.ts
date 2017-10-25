// this import should be first in order to load some required settings (like globals and reflect-metadata)
import { platformNativeScript } from "nativescript-angular/platform-static";

import { AppModuleNgFactory } from "./app.module.ngfactory";

import * as elementRegistryModule from 'nativescript-angular/element-registry';
elementRegistryModule.registerElement("CardView", () => require("nativescript-cardview").CardView);

platformNativeScript().bootstrapModuleFactory(AppModuleNgFactory);
