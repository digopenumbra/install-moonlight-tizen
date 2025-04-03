# Install Moonlight for Samsung TV

**This is a fork from https://github.com/Georift original work on https://github.com/Georift/install-jellyfin-tizen.
I only updated this to be able to install Moonlight on my TV running Tizen OS 8.0. This verstion has issues when installing not signed apps.**


1. Uninstall any existing Moonlight installations

2. Place TV in developer mode

3. Find the TV IP address

4. Copy both your author.p12 and distributor.p12 certificates to your current working directory

Command:
```bash
docker run --rm -v "$(pwd)/author.p12":/certificates/author.p12 -v "$(pwd)/distributor.p12":/certificates/distributor.p12 ghcr.io/digopenumbra/install-moonlight-tizen <samsung tv ip> Moonlight [tag url] [certificate password]
