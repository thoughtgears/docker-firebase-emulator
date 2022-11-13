# Firebase emulator

Docker version of the firebase emulator. Built to be used in docker-compose for testing and local development. Supports GRPC for firestore and pub/sub.  
Will require some specific config in to work properly and since it uses some features like data export, installation of NPM packages for the firebase emulator  
and other small tips and tricks. 

## Initial setup
In your repository you should have a firebase directory at the root of the docker-compose.yaml, it should contain all your different emulator folders and tests.  
This will be linked to your container and will be installed and tested. You will also need a .env file or paste the values into the compose file to substitute the default  
environment variables in the compose file. You also need a firebase/firebase.json file to configure firebase to enable UI and ensure they are started on the ports for the emulator.  

Emulators used is a csv list of emulators to start up during the initial phase.

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

#### Env sample

```dotenv
FIREBASE_TOKEN=
FIREBASE_PROJECT=the-project
EMULATORS_USED="auth,functions,firestore,pubsub,storage"
```

#### Docker Compose

```yaml
  emulator:
    image: my-docker-repo.io/emulator:latest
    entrypoint: "/usr/bin/serve.sh"
    environment:
      FIREBASE_AUTH_EMULATOR_HOST: "localhost:9099"
      FIRESTORE_EMULATOR_HOST: "localhost:8080"
      PUBSUB_EMULATOR_HOST: "localhost:8085"
      FUNCTIONS_EMULATOR_HOST: "localhost:5001"
      FIREBASE_PROJECT: ${FIREBASE_PROJECT}
      GCLOUD_PROJECT: ${FIREBASE_PROJECT}
      FORCE_COLOR: 'true'
      EMULATORS_USED: ${EMULATORS_USED}
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
      - ./firebase:/usr/src/firebase:rw
      - ./cache:/root/.cache/:rw
      - ~/.config/:/root/.config
```
