---
description: Renew the expired iOS distribution certificate and provisioning profile, and update the CI secrets
---

Renew the iOS distribution certificate. Certificates expire annually; this is the fix when the build fails with "No certificate for team matching 'Apple Distribution'" or "Provisioning profile expired".

Part of this requires Apple Developer account access, so it is a collaboration: generate the CSR, then hand off to the user and wait for the downloaded files before continuing.

## The user does (requires Apple Developer account access)

1. **Generate a CSR** — run this for them:
   ```
   openssl req -new -newkey rsa:2048 -nodes \
     -keyout ~/Downloads/fivekmrun_dist.key \
     -out ~/Downloads/fivekmrun_dist.csr \
     -subj "/emailAddress=emil.tabakov@gmail.com/CN=Emil Tabakov/C=BG"
   ```

2. **Create a new Distribution Certificate** at [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates):
   - Click **+** → choose **Apple Distribution**
   - Upload `~/Downloads/fivekmrun_dist.csr`
   - Download the resulting `.cer` file

3. **Recreate the provisioning profile** at [developer.apple.com/account/resources/profiles](https://developer.apple.com/account/resources/profiles):
   - Click **+** → **App Store Connect**
   - App ID: select **`bg.5kmpark.5kmrun`** (NOT the wildcard — it doesn't support Push Notifications or Associated Domains)
   - Certificate: select the new **Apple Distribution: 5 KM PARK BG**
   - Name it `5kmrun-distribution-profile` → **Generate** → **Download**

4. Drop both files in `~/Downloads/` and say so.

## You do (automated, once the files are in place)

1. Convert the `.cer` + private key to a `.p12` (password: `fivekmrun2026`):
   ```
   openssl x509 -inform der -in ~/Downloads/distribution*.cer -out ~/Downloads/fivekmrun_dist.pem
   openssl pkcs12 -export -inkey ~/Downloads/fivekmrun_dist.key -in ~/Downloads/fivekmrun_dist.pem \
     -out ~/Downloads/fivekmrun_dist.p12 -passout pass:fivekmrun2026 -name "Apple Distribution: 5 KM PARK BG"
   ```
2. Read the new provisioning profile UUID:
   ```
   security cms -D -i ~/Downloads/*.mobileprovision | plutil -extract UUID xml1 -o - -
   ```
3. Update three GitHub secrets (`production` environment):
   - `IOS_P12_BASE64` — base64 of the `.p12`
   - `IOS_P12_PASSWORD` — `fivekmrun2026`
   - `IOS_PROVISIONING_PROFILE_BASE64` — base64 of the `.mobileprovision`
4. Update the provisioning profile UUID in two places:
   - `PROVISIONING_PROFILE=<uuid>` in `.github/workflows/upload-appstore.yml`
   - `IOS_EXPORT_OPTIONS` variable at the **`production` environment** level (not repo level — environment takes precedence)
5. Commit and push the workflow change, then re-trigger the build.

## Key gotchas learned

- The `IOS_EXPORT_OPTIONS` variable exists at both repo and `production` environment level — always update the **environment** one or the build will use the old UUID
- Always use App ID `bg.5kmpark.5kmrun`, never the XC wildcard — the wildcard doesn't include Push Notifications or Associated Domains entitlements
- The private key (`fivekmrun_dist.key`) is generated locally and never stored in the repo — keep it in `~/Downloads/` until the process is complete
