# Device Tracker (macOS)

Device Tracker is a macOS app built with SwiftUI that helps you
log and organize devices.\
It's made for tracking inventory, checking maintenance status, and
exporting reports --- all stored locally on your Mac.

------------------------------------------------------------------------

## Overview

The app lets you: - Add, edit, and remove device entries
- View and filter data from a clean dashboard
- Export audit reports to CSV
- Set up local notifications for maintenance reminders
- Use it fully offline --- all data is saved with SwiftData

------------------------------------------------------------------------

## Features

-   Add and edit device records
-   Dashboard with tabbed navigation
-   Local notifications for reminders
-   SwiftData for local storage
-   Export reports in CSV format

------------------------------------------------------------------------

## Requirements

-   macOS 13 (Ventura) or later
-   Xcode 15 or later

------------------------------------------------------------------------

## Build Instructions

1.  Clone the repository:

    ``` bash
    git clone https://github.com/CastroJ12/Device-Tracker-MacApp.git
    cd Device-Tracker-MacApp
    ```

2.  Open the project in Xcode:

        open DeviceTrackerMacApp.xcodeproj

3.  Build and run the app:

    -   Select the `DeviceTracker` target
    -   Press **Build (⌘ + B)**
    -   Press **Run (⌘ + R)**


------------------------------------------------------------------------

## Project Structure

  ----------------------------------------------------------------------------------
  File                             Description
  -------------------------------- -------------------------------------------------
  `DeviceTrackerApp.swift`         Main app entry point

  `ContentView.swift`              Core layout

  `AddDeviceSheet.swift` /         Add and edit modals
  `EditDeviceSheet.swift`          

  `AuditReportsView.swift`         Generates and exports CSV reports

  `NotificationManager.swift`      Manages local notifications

  `MaintenanceSessionView.swift`   Handles maintenance view

  `Device.swift`                   SwiftData model for devices

  `SaveSync.swift`                 Manages save and sync operations

  `DeviceTracker.entitlements`     App permissions

  `Assets.xcassets`                Icons and images
  ----------------------------------------------------------------------------------

------------------------------------------------------------------------

## Notes for Development

-   Data is stored locally using SwiftData.\
-   CSV export is handled in `AuditReportsView.swift`.\
-   Notifications are configured in `NotificationManager.swift`.\
-   No external services or network dependencies are used.

