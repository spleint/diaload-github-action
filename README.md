# [<img src="https://cdn.diaload.com/assets/images/img-logo-text-green.svg" alt="Diaload"/>](https://diaload.com/) 

# Dialaod Github Action

### Current version: v1

> BETA mode. Your feedback is highly appreciated!

[![Workflow to upload APK and IPA to Diaload app distribution](https://github.com/spleint/diaload-github-action/actions/workflows/main.yml/badge.svg)](https://github.com/spleint/diaload-github-action/actions/workflows/main.yml)

This action uploads artifacts (.apk or .ipa) to Diaload and notifies your team members about it.

## Configuration

_More info here: [https://www.npmjs.com/package/diaload-cli](https://www.npmjs.com/package/diaload-cli)_

| Key               | Description                                                                                                                                                                                                                                                                                                                                                                                   | Env Var(s)                | Default |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------| ------- |
| api_token         | You can get it using the CLI tool https://www.npmjs.com/package/diaload-cli#6-create-access-token                                                                                                                                                                                                                                                                                             | DIALOAD_API_TOKEN         |         |
| app_id            | You can get it from your app page at [https://https://www.npmjs.com/package/diaload-cli#4-list-apps](https://https://www.npmjs.com/package/diaload-cli#4-list-apps)                                                                                                                                                                                                                           | DIALOAD_APP_ID            |         |
| release           | It can be either both or Android or iOS                                                                                                                                                                                                                                                                                                                                                       | DIALOAD_RELEASE           |         |
| file              | Path to the either Android .APK file or iOS .IPA file                                                                                                                                                                                                                                                                                                                                         | DIALOAD_FILE_PATH         |         |
| release_notes     | Manually add the release notes to be displayed for the testers                                                                                                                                                                                                                                                                                                                                | DIALOAD_RELEASE_NOTES     |         |
| git_release_notes | Collect release notes from the latest git commit message to be displayed for the testers: true or false                                                                                                                                                                                                                                                                                       | DIALOAD_GIT_RELEASE_NOTES | true    |
| git_commit_id     | Include the last commit ID in the release notes (works if git_release_notes is set true or false)                                                                                                                                                                                                                                                                                             | DIALOAD_GIT_COMMIT_ID     | false   |
| group_id          | If you want to assign this release to a group, specify the valid group ID. If the ID is invalid the release will still be created, but not assigned to any group and the script will succeed. You can query group IDs using the cli tool [https://docs.diaload.com/docs/diaload-cli/available-commands#list-groups](https://docs.diaload.com/docs/diaload-cli/available-commands#list-groups) | GROUP_ID                  |         |

## Requirements

This action will **execute on runners with Ubuntu & macOS operating systems**.

## Sample usage for Android

```
name: Android adhoc
on:
  push:
    branches:
      - code-sign

jobs:
  export_android:

    runs-on: ubuntu-latest

    steps:

    - name: Checkout repository
    - uses: actions/checkout@v2

    - name: Set up JDK 1.8
      uses: actions/setup-java@v1
      with:
        java-version: 1.8

    - name: Build release
      run: ./gradlew assembleRelease

    - name: Upload APK to Diaload
      uses: spleint/diaload-github-action@v1
      with:
        api_token: ${{secrets.DIALOAD_API_TOKEN}}
        app_id: "abc-123-xyz"
        file: app/build/outputs/apk/release/app-release-unsigned.apk
        release_notes: "My awesome release notes..."
        git_release_notes: true
        include_git_commit_id: false
```

If you want a debug version, replace the following:

`run: ./gradlew assembleDebug`

`file: app/build/outputs/apk/debug/app-debug.apk`

## Sample usage for iOS

```
name: iOS adhoc
on:
  push:
    branches:
      - code-sign

jobs:
  export_ios_with_signing:
    runs-on: macos-11

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Build and export iOS
        uses: spleint/diaload-github-action@v1
        with:
          project-path: ios/diaload.xcodeproj
          workspace-path: ios/diaload.xcworkspace
          scheme: diaload
          export-method: ad-hoc
          configuration: Release
          output-path: artifacts/output.ipa
          p12-base64: ${{ secrets.P12_BASE64 }}
          certificate-password: ${{ secrets.P12_PASSWORD }}
          mobileprovision-base64: ${{ secrets.ADHOC_MOBILEPROVISION_BASE64 }}
          code-signing-identity: ${{ secrets.CODE_SIGNING_IDENTITY }}
          team-id: ${{ secrets.TEAM_ID }}

      - name: Upload IPA to Diaload
        uses: spleint/github-action@v1
        with:
          api_token: ${{ secrets.DIALOAD_API_TOKEN }}
          app_id: ${{ secrets.DIALOAD_APP_ID }}
          file: artifacts/output.ipa
          release_notes: "Testing manual release notes..."
          git_release_notes: true
          include_git_commit_id: false
```

---

## Feedback & Support

Developers built [Diaload](https://diaload.com) to solve the pain of acquiring testers, app distribution & feedback for mobile app development teams.

Check out our [Help Center](https://docs.diaload.com/) for more info and other integrations.

Happy releasing 🎉
