import { AppiumDriver, createDriver, SearchOptions } from "nativescript-dev-appium";
import { assert } from "chai";

describe("basic tests", () => {
    const defaultWaitTime = 5000;
    let driver: AppiumDriver;

    before(async () => {
        driver = await createDriver();
    });

    after(async () => {
        await driver.quit();
        console.log("Quit driver!");
    });

    afterEach(async function () {
        if (this.currentTest.state === "failed") {
            await driver.logTestArtifacts(this.currentTest.title);
        }
    });

    it("application starts successfully", async () => {
        const usernameField = await driver.findElementByClassName(driver.locators.getElementByName("textfield"));

        assert.isTrue(await usernameField.exists());
    });
});