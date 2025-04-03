#!/bin/bash

if [ -z "$1" ]; then
    echo "Please pass the IP address of your Samsung TV as part of the commandline arguments for this script.";
		exit 1;
fi

MOONLIGHT_BUILD_OPTION="${2:-Moonlight}";
TAG_URL="${3:-https://github.com/OneLiberty/moonlight-chrome-tizen/releases/latest}";

if [ -z "$2" ]; then
    echo "Build option not provided, using default one: $MOONLIGHT_BUILD_OPTION";
	echo "You can change it by passing option name as second argument for this script.";
fi

if [ -z "$3" ]; then
	FULL_TAG_URL=$(curl -sLI $TAG_URL | grep -i 'location:' | sed -e 's/^[Ll]ocation: //g' | tr -d '\r');

	# Check if FULL_TAG_URL is not empty and valid
	if [ -z "$FULL_TAG_URL" ]; then
		echo "Error: Could not fetch the latest tag URL from $TAG_URL"
		exit 1
	fi
 
	TAG=$(basename "$FULL_TAG_URL");
	echo "Tag URL not provided, using the latest available version: $TAG";
	echo "You can change it by passing tag URL as third argument for this script.";
else
	# Extract the tag name from the provided TAG_URL
	TAG=$(basename "$TAG_URL")
 
	# Check if TAG is not empty
	if [ -z "$TAG" ]; then
		echo "Error: Could not extract the tag from the provided URL $TAG_URL"
		echo "Please provide a URL to the full release, for example: https://github.com/jeppevinkel/jellyfin-tizen-builds/releases/tag/2024-11-24-0431"
  		echo "Otherwise, don't provide a URL and the latest version will be installed."
		exit 1
	fi
fi

if [ -z "$4" ]; then
	echo "Certificate information not provided, using default dev certificate."
else
	if [ -f /certificates/author.p12 ] && [ -f /certificates/distributor.p12 ]; then
		CERTIFICATE_PASSWORD=$4
	else
		echo "Certificate information provided but certificate files not found."
		exit 1
	fi
fi	

DOWNLOAD_URL=$(echo https://github.com/OneLiberty/moonlight-chrome-tizen/releases/download/${TAG}/${MOONLIGHT_BUILD_OPTION}.wgt);

echo ""
echo ""
echo "	Thanks to https://github.com/OneLiberty for providing the pre-packaged moonlight-chrome-tizen builds!";
echo "	These builds can be found at https://github.com/OneLiberty/moonlight-chrome-tizen";
echo ""
echo ""
echo "	All credits to https://github.com/Georift for providing this Dockerfile and scripts.";
echo "	You can find the original project here: https://github.com/Georift/install-jellyfin-tizen.";
echo ""
echo "" 
echo "	Using Moonlight Tizen Build $MOONLIGHT_BUILD_OPTION.wgt";
echo "	from release: $TAG";
echo ""
echo ""

TV_IP="$1";

echo "Attempting to connect to Samsung TV at IP address $TV_IP"
sdb connect $1

echo "Attempting to get the TV name..."
TV_NAME=$(sdb devices | grep -E 'device\s+\w+[-]?\w+' -o | sed 's/device//' - | xargs)

if [ -z "$TV_NAME" ]; then
    echo "We were unable to find the TV name.";
		exit 1;
fi
echo "Found TV name: $TV_NAME"

echo "Downloading moonlight-chrome-tizen $MOONLIGHT_BUILD_OPTION.wgt from release: $TAG"
wget -q --show-progress "$DOWNLOAD_URL"; echo ""

if ! [ -z "$CERTIFICATE_PASSWORD" ]; then
	echo "Attempting to sign package using provided certificate"
	sed -i "s/_CERTIFICATEPASSWORD_/$CERTIFICATE_PASSWORD/" profile.xml
	sed -i '/<\/profile>/ r profile.xml' /home/developer/tizen-studio-data/profile/profiles.xml
	tizen package -t wgt -s custom -- $MOONLIGHT_BUILD_OPTION.wgt
fi

echo "Attempting to install jellyfin-tizen-builds $MOONLIGHT_BUILD_OPTION.wgt from release: $TAG"
tizen install -n $MOONLIGHT_BUILD_OPTION.wgt -t "$TV_NAME"
