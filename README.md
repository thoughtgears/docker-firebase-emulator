# Firebase emulator

Docker version of the firebase emulator. Built to be used in docker-compose for testing and local development. Supports
GRPC for firestore and pub/sub. Will require some specific config in to work properly and since it uses some features
like data export, installation of NPM packages for the firebase emulator and other small tips and tricks.

## Initial setup

In your repository you should have a firebase directory at the root of the compose.yaml, it should contain all
your different emulator folders and tests. This will be linked to your container and will be installed and tested.
Example of the directory structure and files can be found in the [example](./example) directory.

- [firebase](./example/firebase) **(Required)**: The directory where you will store your firebase emulator configuration
  and data.
- [compose.yaml](./example/compose.yml) **(Required)**: The docker-compose file that will start the emulator and your
  tests.

**IMPORTANT**: In the `firebase` directory you must have a `data/export` directory if you opt in to store data, this is
due to how the firebase emulator works and how it stores data. Since when exporting data, it will create a temporary
directory in the `data` directory and then rename it to the `export` location, and prior to the rename, it will remove
the example directory.

#### Firebase

Short example of a `firebase/firebase.json` file to use with your project

```json
{
  "emulators": {
    "ui": {
      "enabled": true,
      "port": "4000"
    },
    "hub": {
      "port": "4400"
    },
    "logging": {
      "port": "4600"
    },
    "functions": {
      "port": "5001"
    },
    "firestore": {
      "port": "8080"
    },
    "pubsub": {
      "port": "8085"
    },
    "database": {
      "port": "9000"
    },
    "auth": {
      "port": "9099"
    },
    "storage": {
      "port": "9199"
    },
    "hosting": {
      "port": "6000"
    }
  }
}
```

#### Docker Compose

```yaml
 services:
   emulator:
     build: # Can change this to a prebuilt image as well
       context: ./emulator
       dockerfile: Dockerfile
       args:
         - FIREBASE_VERSION=13.3.0 # Set to latest version
     stop_grace_period: 1m
     environment:
       FIREBASE_AUTH_EMULATOR_HOST: "localhost:9099"
       FIRESTORE_EMULATOR_HOST: "localhost:8080"
       PUBSUB_EMULATOR_HOST: "localhost:8085"
       FUNCTIONS_EMULATOR_HOST: "localhost:5001"
       FIREBASE_PROJECT: "test-project" # Can be set to a real project_id or a mock one
       GCLOUD_PROJECT: "test-project" # Can be set to a real project_id or a mock one
       FORCE_COLOR: 'true'
       DATA_DIRECTORY: "data" # The directory where you will store data
       CHOKIDAR_USEPOLLING: 'true'
     healthcheck:
       test: "netstat -an | grep -c 4000"
       interval: 20s
       timeout: 20s
       retries: 10
     ports:
       - "4000:4001" # ui
       - "4400:4401" # hub
       - "4600:4601" # logging
       - "5001:5002" # functions
       - "8080:8081" # firestore
       - '8082:9081' # firestore (grpc)
       - "8085:8086" # pubsub
       - "9000:9001" # database
       - "9099:9100" # auth
       - '9229:9230' # cloud_functions_debug
       - '9199:9200' # Storage
       - '6000:6001' # Hosting
     volumes:
       - ./firebase:/srv/firebase:rw
       - ./cache:/root/.cache/:rw
       - ~/.config/:/root/.config
       - ./firebase/data:/srv/firebase/data:rw
```
