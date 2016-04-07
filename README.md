# React Native Sqlite

A react native wrapper for SQLite

## Description

A simple wrapper for SQLite, for both iOS and Android.

Based on (https://github.com/jbrodriguez/react-native-android-sqlite).

## Setup

* Install Module

```bash
npm install --save jbrodriguez/rn-sqlite
```

### Android
* `android/settings.gradle`

```gradle
...
include ':rn-sqlite'
project(':rn-sqlite').projectDir = new File(settingsDir, '../node_modules/rn-sqlite/android')
```

* `android/app/build.gradle`

```gradle
dependencies {
	...
	compile project(':rn-sqlite')
}
```

* register module (in MainActivity.java)

```java
...

import io.jbrodriguez.react.RNSQLiteModule; // <--- import 

public class MainActivity extends ReactActivity {

...

    /**
     * A list of packages used by the app. If the app uses additional views
     * or modules besides the default ones, add more packages here.
     */
    @Override
    protected List<ReactPackage> getPackages() {
        return Arrays.<ReactPackage>asList(
            new MainReactPackage(),
            new RNSQLiteModule()  // <--- add here
        );
    }
}
```

### iOS
In XCode, in the project navigator, right click Libraries ➜ Add Files to [your project's name] Go to node_modules ➜ rn-sqlite and add the .xcodeproj file

In XCode, in the project navigator, select your project, add libRNSQLite.a from the RNSQLite.xcodeproj/Products folder to your project's Build Phases ➜ Link Binary With Libraries.

Click RNSQLite.xcodeproj you added before in the project navigator and go the Build Settings tab. Make sure 'All' is toggled on (instead of 'Basic').

Look for Header Search Paths and make sure it contains both $(SRCROOT)/../../react-native/React and $(SRCROOT)/../../React - mark both as recursive.

## Usage

- Android
This library depends on [SQLiteAssetHelper](https://github.com/jgilfelt/android-sqlite-asset-helper).

The idea is that you `import` your previously created database as an application asset.

SQLiteAssetHelper manages schema definition (create), as well as upgrades.

For more information refer to [SQLiteAssetHelper's docs](https://github.com/jgilfelt/android-sqlite-asset-helper) and/or check [SQLiteOpenHelper](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html)

So, the first step involves copying your sqlite db to the following folder

```
<YourProject>/android/app/src/main/assets/databases
```
Substitute `<YourProject>` with the folder where your app resides, i.e. AwesomeProject.

- iOS
Drag and Drop or add your sqlite db to your XCode project.

## API
You can start interacting with the db, through 4 public functions:

- init
- query
- exec
- close

### Init
The database must be initialized before any other call takes place

```js
import SQLite from 'react-native-android-sqlite'

const databaseName = 'app.db'

SQLite.init(databaseName).then( () => {
	console.log('database initialized.')
})
```

### Exec
pre-requisite: the db must have been initialized

```js
import SQLite from 'react-native-android-sqlite'

const sql = 'INSERT INTO todo(name, completed) VALUES (?, ?)'
const params = ["Create rn-sqlite", 1]

SQLite.exec(sql, params)then( () => {
	console.log('row inserted.')
})

```

### Query
pre-requisite: the db must have been initialized

```js
import SQLite from 'react-native-android-sqlite'

const sql = 'SELECT * FROM todo WHERE completed = ?'
const params = [1]

SQLite.query(sql, params).then( (data) => {
	console.log('retrieved: ', data)
})
// retrieved: {"completed": 1, "name": "Create rn-sqlite"}
```

### Close
pre-requisite: the db must have been initialized

```js
import SQLite from 'react-native-android-sqlite'

SQLite.close().then( () => {
    console.log('database closed')
})
```

## Known Issues
* It doesn't return the id for a newly inserted row (maybe create a separate insert function ?)
* Column types currently supported are Integer and String
* Additional error handling should be implemented

## Changes
Please submit any PR's you seem fit.

## Credits
* [React Native](https://facebook.github.io/react-native/) - Awesome software.
* [Android SQLiteAssetHelper](https://github.com/jgilfelt/android-sqlite-asset-helper) - Simplifying the handling of Android's sqlite interface
* [React Native Android Badge](https://github.com/jhen0409/react-native-android-badge) - For showing me the light with regards to the gradle build system, as applied to react native

## LICENSE

MIT