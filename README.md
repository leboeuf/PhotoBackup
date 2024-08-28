# PhotoBackup

This is a Swift-based console application designed to download photos and videos from all the Shared Albums of the currently logged-in iCloud user.

# Usage

```
git clone https://github.com/leboeuf/PhotoBackup.git
cd PhotoBackup
swift build && swift run
```

# Overview

When you run this tool for the first time, it will request access to your photo library. It will then proceed to loop through each Shared Album, download all photos, videos, and Live Photos sequentially, and store the IDs of downloaded media in a SQLite database (one database file per album).

Subsequent runs will check the database and only download new media that hasn't been saved previously.

Everything will be saved to: `/Users/[user]/Downloads/PhotoBackupOutput/`. The tool will create one folder per Shared Album, plus one global `_db` folder containing one `.sqlite` file per album. The files will be named using the following format: `[creation date]_[creation time]_[original UUID].[ext]`.

Example: `20240103_231805_0B1EBBEA-C159-4ADD-BE47-A7F567C70EDD.HEIC`

# Limitations

## Rate limits and media quality

Downloading from large Shared Albums may cause you to hit Apple's rate limits. Downloads seem limited to 1000 per hour and 10,000 per day.

Also note that photos and videos in Shared Albums are resized from their original version (2048 pixels on the long edge for photos, 720p for videos).

You can read more on the limitations of shared albums here: https://support.apple.com/en-us/108916

## Metadata

Please be aware that videos downloaded using this tool won't retain their original metadata (creation date, location, etc.).
