# [DEPRECIATED]
[This issue](https://github.com/jeppevinkel/jellyfin-tizen-builds/issues/32) was closed in [jellyfin-tizen-builds](https://github.com/jeppevinkel/jellyfin-tizen-builds/tree/master) to address this need.

## Jellyfin Tizen build with TrueHD support

See [this comment](https://github.com/jellyfin/jellyfin-tizen/issues/226#issuecomment-1765771658) in the jellyfin-tizen repo which states how to add TrueHD support to the jellyfin client to allow direct play of TrueHD Audio.

The inclueded Dockerfile will build a copy of Jellyfin.wgt, which you can exec into the conatiner to deploy with sdb.

## Steps

1. Build the Dockerfile and tag it however you want. 
`docker build . -t jt-truehd`
2. Run the container to get a shell to deploy the app from. 
`docker exec --rm --name tizen jt-truehd`
3. Use sdb to connect to your TV and get the device name:
`/tizen/tizen-studio/tools/sdb connect 1.2.3.4`
`/tizen/tizen-studio/tools/sdb devices`
4. Deploy the package to the TV. Make sure the existing Jellyfin app is uninstalled prior.
`/tizen/tizen-studio/tools/ide/bin/tizen install -n /tizen/jellyfin-tizen/Jellyfin.wgt -t DEVICENAME`

## Credits

This is a blatant ripoff of [jellyfin-tizen-builds](https://github.com/jeppevinkel/jellyfin-tizen-builds/tree/master), so all credit to them.

I opened [this issue](https://github.com/jeppevinkel/jellyfin-tizen-builds/issues/32) to request a separate build to add this feature, as not all clients need TrueHD.
