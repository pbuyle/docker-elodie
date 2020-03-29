# elodie-docker

Docker container for [Elodie](https://github.com/jmathai/elodie)

<p align="center"><img src ="https://raw.githubusercontent.com/jmathai/elodie/master/creative/logo@300x.png" /></p>

The container default command is to watch a source folder using `inotifywait` and automatically execute `elodie` to import added images to a destination folder. 

## Usage

```
docker run \
  -name elodie
  -v /path/to/source:/source \
  -v /path/to/destination:/destination \
  -e PUID=1000 \
  -e PGID=1000 \
  --restart unless-stopped \
  pbuyle/elodie
```

## Configuration

### Environment Variables

| Name                         | default value | Description
| ---------------------------- |:-------------:| -----------
| PUID                         | 1000          | for GroupID - see below for explanation
| PGID                         | 1000          | for GroupID - see below for explanation
| SOURCE                       | /source       | Copy imported files into this directory
| DESTINATION                  | /destination  | Import files from this directory, if specified
| TRASH                        |               | After copying files, move the old files to this trash folder
| EXCLUDE                      |               | Regular expression for directories or files to exclude
| MAPQUEST_KEY                 |               | Mapquest API key for geo-code location from EXIF's GPS fields
| ELODIE_APPLICATION_DIRECTORY | /elodie       | Fully qualified directory path to the configuration file folder

### Advanced configurtion

Mount a custom `config.ini` to set configuration.

Note: If a custom configuartion file is used, the setting the `MAPQUEST_KEY` environment variable will have not effect.

### User / Group Identifiers

When using volumes (-v flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user PUID and group PGID.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance PUID=1000 and PGID=1000, to find yours use id user as below:
```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```