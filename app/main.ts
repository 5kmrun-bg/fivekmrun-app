// this import should be first in order to load some required settings (like globals and reflect-metadata)
import { platformNativeScriptDynamic } from "nativescript-angular/platform";
import { AppModule } from "./app.module";
import * as firebase from "nativescript-plugin-firebase";

import * as elementRegistryModule from 'nativescript-angular/element-registry';
elementRegistryModule.registerElement("CardView", () => require("nativescript-cardview").CardView);

firebase.init({
    onMessageReceivedCallback: function(message) {
        console.log("Title: " + message.title);
        console.log("Body: " + message.body);
        // if your server passed a custom property called 'foo', then do this:
        console.log("Value of 'foo': " + message.data.foo);
      }
  }).then(
    (instance) => {
      console.log("firebase.init done");
    },
    (error) => {
      console.log(`firebase.init error: ${error}`);
    }
  );

platformNativeScriptDynamic().bootstrapModule(AppModule);
